// =====================================================
// SISTEM TAMBAHAN
// Berisi: layar penuh, skin bola, toko skin, pencapaian (achievement), toast
// notifikasi, dan penyimpanan data permanen (koin dompet, skin, pencapaian).
// =====================================================

// ---------- LAYAR PENUH ----------
// Jendela dibuat langsung memenuhi layar (maximized) TETAPI tetap punya bar judul
// sehingga tombol minimize / restore / close masih ada. F11 = mode fullscreen penuh.
GLWindow jendelaGL = null;

// Dipanggil sekali dari draw() setelah game berjalan. Semua perubahan jendela dijalankan
// di thread terpisah supaya thread animasi tidak saling menunggu (deadlock) dengan thread jendela.
void aturLayarPenuh() {
  surface.setTitle("BOUNCE");
  try {
    jendelaGL = (GLWindow) surface.getNative();
  }
  catch (Throwable e) {
    jendelaGL = null;
    println("Jendela tidak bisa di-maximize otomatis: " + e);
    return;
  }
  Thread t = new Thread(new Runnable() {
    public void run() {
      try {
        jendelaGL.setResizable(true);
        jendelaGL.setMaximized(true, true);
      }
      catch (Throwable e) {
        println("Gagal maximize jendela: " + e);
      }
    }
  }
  );
  t.start();
}

// Menukar antara jendela maximized (ada tombol minimize) dan fullscreen murni.
void ubahLayarPenuh() {
  if (jendelaGL == null) return;
  Thread t = new Thread(new Runnable() {
    public void run() {
      try {
        jendelaGL.setFullscreen(!jendelaGL.isFullscreen());
      }
      catch (Throwable e) {
        println("Gagal mengubah mode layar penuh: " + e);
      }
    }
  }
  );
  t.start();
}

// ---------- KOORDINAT MOUSE (karena tampilan di-scale mengikuti ukuran layar) ----------
float mx() {
  return mouseX / SK;
}

float my() {
  return mouseY / SK;
}

// ---------- SKIN BOLA ----------
final int JUMLAH_SKIN = 5;
String[] skinNama = {"MERAH", "BIRU", "HIJAU", "KUNING", "YIN YANG"};
String[] skinDesk = {"Bola klasik", "Biru samudra", "Hijau rimba", "Kuning emas", "Dua sisi seimbang"};
int[] skinHarga = {0, 100, 200, 300, 500};
color[] skinGelap = {color(120, 15, 15), color(15, 40, 130), color(15, 95, 35), color(150, 105, 0), color(25)};
color[] skinTengah = {color(195, 35, 35), color(40, 90, 210), color(40, 160, 70), color(225, 170, 20), color(30)};
color[] skinTerang = {color(235, 55, 45), color(70, 140, 255), color(80, 210, 100), color(255, 215, 60), color(250)};
color[] skinBintik = {color(255, 190, 160), color(190, 225, 255), color(200, 255, 200), color(255, 250, 190), color(250)};

int skinAktif = 0;
boolean[] skinMilik = new boolean[JUMLAH_SKIN];

// Menggambar bola dengan skin s di titik (0,0) (pemanggil yang melakukan translate).
void bolaSkin(int s, float r, float rot) {
  noStroke();
  if (s == 4) {
    // Skin YIN YANG: lingkaran hitam-putih yang ikut berputar saat menggelinding.
    fill(25);
    ellipse(0, 0, r * 2 + 4, r * 2 + 4);
    pushMatrix();
    rotate(rot);
    fill(250);
    ellipse(0, 0, r * 2, r * 2);
    fill(20);
    arc(0, 0, r * 2, r * 2, -HALF_PI, HALF_PI, PIE);
    fill(20);
    ellipse(0, -r / 2, r, r);
    fill(250);
    ellipse(0, r / 2, r, r);
    fill(250);
    ellipse(0, -r / 2, r * 0.28, r * 0.28);
    fill(20);
    ellipse(0, r / 2, r * 0.28, r * 0.28);
    popMatrix();
    return;
  }
  fill(skinGelap[s]);
  ellipse(0, 0, r * 2 + 4, r * 2 + 4);
  fill(skinTengah[s]);
  ellipse(0, 0, r * 2, r * 2);
  fill(skinTerang[s]);
  ellipse(-2, -2, r * 1.72, r * 1.72);
  pushMatrix();
  rotate(rot);
  fill(skinBintik[s]);
  ellipse(r * 0.5, -r * 0.35, r * 0.4, r * 0.4);
  fill(255, 255, 255, 200);
  ellipse(-r * 0.45, r * 0.4, r * 0.22, r * 0.22);
  popMatrix();
}

void bola3D(float x, float y, float r, int s, float rot) {
  hint(ENABLE_DEPTH_TEST);
  lightFalloff(1, 0, 0);
  ambientLight(120, 120, 120);
  directionalLight(230, 230, 230, -0.4, 0.6, -1);
  pushMatrix();
  translate(x, y, 0);
  rotateX(0.4);
  rotateY(rot);
  noStroke();
  fill(skinTengah[s]);
  sphere(r);
  fill(skinTerang[s]);
  translate(r * 0.6, -r * 0.3, r * 0.7);
  sphere(r * 0.2);
  popMatrix();
  noLights();
  hint(DISABLE_DEPTH_TEST);
}

void kotak3D(float x, float y, float s, float rot, color c) {
  hint(ENABLE_DEPTH_TEST);
  lightFalloff(1, 0, 0);
  ambientLight(120, 120, 120);
  directionalLight(230, 230, 230, -0.4, 0.6, -1);
  pushMatrix();
  translate(x, y, 0);
  rotateX(0.5);
  rotateY(rot);
  noStroke();
  fill(c);
  box(s);
  popMatrix();
  noLights();
  hint(DISABLE_DEPTH_TEST);
}

// ---------- DATA PERMANEN ----------
int dompet = 0;               // koin permanen yang bisa dibelanjakan
int statKoinTotal = 0;        // total koin yang pernah diambil
int statLompat = 0;
int statMati = 0;
int statCheckpoint = 0;
int statSkorTertinggi = 0;
int matiDiLevel = 0;          // dipakai pencapaian "Tanpa Luka"
boolean dataKotor = false;

String fileSimpan() {
  return sketchPath("pa_grafika_save.txt");
}

String boolKeTeks(boolean[] a) {
  String s = "";
  for (int i = 0; i < a.length; i++) {
    s += (a[i] ? "1" : "0");
    if (i < a.length - 1) s += ",";
  }
  return s;
}

void teksKeBool(String v, boolean[] a) {
  String[] p = split(v, ',');
  for (int i = 0; i < min(p.length, a.length); i++) {
    a[i] = p[i].equals("1");
  }
}

void muatData() {
  skinMilik[0] = true;
  try {
    File f = new File(fileSimpan());
    if (!f.exists()) return;
    String[] baris = loadStrings(f.getAbsolutePath());
    if (baris == null) return;
    for (int i = 0; i < baris.length; i++) {
      String[] kv = split(baris[i], '=');
      if (kv.length < 2) continue;
      String k = trim(kv[0]);
      String v = trim(kv[1]);
      if (k.equals("dompet")) dompet = int(v);
      else if (k.equals("skinAktif")) skinAktif = int(v);
      else if (k.equals("koinTotal")) statKoinTotal = int(v);
      else if (k.equals("lompat")) statLompat = int(v);
      else if (k.equals("mati")) statMati = int(v);
      else if (k.equals("checkpoint")) statCheckpoint = int(v);
      else if (k.equals("skorTertinggi")) statSkorTertinggi = int(v);
      else if (k.equals("skinMilik")) teksKeBool(v, skinMilik);
      else if (k.equals("pencapaian")) teksKeBool(v, pencapaianBuka);
    }
  }
  catch (Exception e) {
    println("Gagal memuat data simpanan");
  }
  skinMilik[0] = true;
  skinAktif = constrain(skinAktif, 0, JUMLAH_SKIN - 1);
  if (!skinMilik[skinAktif]) skinAktif = 0;
}

void simpanData() {
  try {
    String[] baris = {
      "dompet=" + dompet,
      "skinAktif=" + skinAktif,
      "koinTotal=" + statKoinTotal,
      "lompat=" + statLompat,
      "mati=" + statMati,
      "checkpoint=" + statCheckpoint,
      "skorTertinggi=" + statSkorTertinggi,
      "skinMilik=" + boolKeTeks(skinMilik),
      "pencapaian=" + boolKeTeks(pencapaianBuka)
    };
    saveStrings(fileSimpan(), baris);
    dataKotor = false;
  }
  catch (Exception e) {
    println("Gagal menyimpan data");
  }
}

// Menyimpan otomatis tiap 3 detik jika ada perubahan (koin, lompatan, dll).
void autosimpan() {
  if (dataKotor && frameCount % 180 == 0) simpanData();
}

// Pastikan data tersimpan saat game ditutup.
void exit() {
  simpanData();
  super.exit();
}

// ---------- PENCAPAIAN (ACHIEVEMENT) ----------
final int JUMLAH_PRESTASI = 14;
String[] prNama = {
  "LANGKAH PERTAMA", "PENDAKI SALJU", "RAJA ES", "PENJELAJAH KRISTAL", "PENAKLUK LAVA",
  "PEMUNGUT KOIN", "KAYA RAYA", "TANPA LUKA", "PELOMPAT ULUNG", "PANTANG MENYERAH",
  "PEMBURU BENDERA", "SKOR TINGGI", "FASHIONISTA", "KOLEKTOR SKIN"
};
String[] prDesk = {
  "Selesaikan Level 1", "Selesaikan Level 2", "Selesaikan Level 3", "Selesaikan Level 4", "Selesaikan Level 5",
  "Kumpulkan 50 koin", "Kumpulkan 250 koin", "Selesaikan level tanpa mati", "Melompat 200 kali", "Kehilangan nyawa 15 kali",
  "Aktifkan 5 checkpoint", "Capai skor 5000", "Beli skin pertama", "Miliki semua skin"
};
int[] prHadiah = {25, 25, 30, 40, 75, 20, 60, 50, 20, 15, 20, 50, 25, 100};
int[] prTarget = {0, 0, 0, 0, 0, 50, 250, 0, 200, 15, 5, 5000, 0, JUMLAH_SKIN};
boolean[] pencapaianBuka = new boolean[JUMLAH_PRESTASI];

ArrayList<Integer> antrianToast = new ArrayList<Integer>();
int toastId = -1;
float toastWaktu = 0;

SoundFile sfxPrestasi, sfxBeli;

void bukaPrestasi(int i) {
  if (i < 0 || i >= JUMLAH_PRESTASI || pencapaianBuka[i]) return;
  pencapaianBuka[i] = true;
  dompet += prHadiah[i];
  antrianToast.add(i);
  mainkanSfx(sfxPrestasi);
  simpanData();
}

// Nilai saat ini untuk pencapaian berbasis hitungan; -1 jika bukan pencapaian hitungan.
int nilaiPrestasi(int i) {
  switch (i) {
  case 5:
  case 6:
    return statKoinTotal;
  case 8:
    return statLompat;
  case 9:
    return statMati;
  case 10:
    return statCheckpoint;
  case 11:
    return statSkorTertinggi;
  case 13:
    return jumlahSkinDimiliki();
  }
  return -1;
}

int jumlahSkinDimiliki() {
  int n = 0;
  for (int i = 0; i < JUMLAH_SKIN; i++) if (skinMilik[i]) n++;
  return n;
}

// Dipanggil tiap frame saat bermain: memeriksa pencapaian berbasis hitungan.
void cekPrestasi() {
  if (skor > statSkorTertinggi) {
    statSkorTertinggi = skor;
    dataKotor = true;
  }
  for (int i = 0; i < JUMLAH_PRESTASI; i++) {
    if (!pencapaianBuka[i] && prTarget[i] > 0 && nilaiPrestasi(i) >= prTarget[i]) {
      bukaPrestasi(i);
    }
  }
}

// Dipanggil ketika sebuah level berhasil diselesaikan.
void prestasiLevelSelesai(int lvl) {
  bukaPrestasi(lvl - 1);
  if (matiDiLevel == 0) bukaPrestasi(7);
  simpanData();
}

// Notifikasi pencapaian yang meluncur dari atas layar.
void gambarToast() {
  if (toastId < 0 && antrianToast.size() > 0) {
    toastId = antrianToast.remove(0);
    toastWaktu = 0;
  }
  if (toastId < 0) return;

  toastWaktu++;
  float durasi = 230;
  float masuk = constrain(toastWaktu / 18.0, 0, 1);
  float keluar = constrain((durasi - toastWaktu) / 18.0, 0, 1);
  float k = min(masuk, keluar);
  k = k * k * (3 - 2 * k);

  float w = 390, h = 74;
  float x = (VW - w) / 2;
  float y = -h + (h + 22) * k;

  noStroke();
  fill(0, 0, 0, 70);
  rect(x + 4, y + 6, w, h, 16);
  fill(255, 250, 215, 250);
  rect(x, y, w, h, 16);
  noFill();
  stroke(230, 165, 20);
  strokeWeight(3);
  rect(x, y, w, h, 16);
  noStroke();

  gambarPiala(x + 40, y + h / 2, 1.0, true);

  fill(180, 120, 10);
  textAlign(LEFT, CENTER);
  textSize(12);
  text("PENCAPAIAN TERBUKA!  +" + prHadiah[toastId] + " KOIN", x + 76, y + 20);
  fill(35, 85, 45);
  textSize(18);
  text(prNama[toastId], x + 76, y + 42);
  fill(90, 110, 90);
  textSize(12);
  text(prDesk[toastId], x + 76, y + 61);

  if (toastWaktu >= durasi) toastId = -1;
}

// Ikon piala sederhana dari bentuk dasar; emas jika terbuka, abu-abu jika terkunci.
void gambarPiala(float x, float y, float s, boolean buka) {
  pushMatrix();
  translate(x, y);
  scale(s);
  noStroke();
  color c1 = buka ? color(255, 205, 35) : color(175, 180, 175);
  color c2 = buka ? color(200, 140, 10) : color(135, 140, 135);
  fill(0, 0, 0, 30);
  ellipse(0, 22, 34, 8);
  fill(c2);
  rect(-10, 14, 20, 6, 2);
  rect(-3, 6, 6, 10);
  noFill();
  stroke(c2);
  strokeWeight(3);
  arc(-14, -4, 14, 14, HALF_PI, PI + HALF_PI);
  arc(14, -4, 14, 14, -HALF_PI, HALF_PI);
  noStroke();
  fill(c1);
  beginShape();
  vertex(-14, -16);
  vertex(14, -16);
  bezierVertex(14, 0, 8, 8, 0, 8);
  bezierVertex(-8, 8, -14, 0, -14, -16);
  endShape(CLOSE);
  fill(255, 255, 255, 120);
  ellipse(-6, -8, 4, 10);
  popMatrix();
}

// ---------- LAYAR PENCAPAIAN ----------
void gambarPrestasi() {
  latarMenu();

  int terbuka = 0;
  for (int i = 0; i < JUMLAH_PRESTASI; i++) if (pencapaianBuka[i]) terbuka++;

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(34);
  text("PENCAPAIAN", VW / 2, 36);
  textSize(15);
  fill(50, 100, 60);
  text(terbuka + " / " + JUMLAH_PRESTASI + " terbuka", VW / 2, 70);

  float lebarBaris = 410, gap = 16, tinggiBaris = 62;
  float x0 = (VW - (lebarBaris * 2 + gap)) / 2;
  float y0 = 96;

  for (int i = 0; i < JUMLAH_PRESTASI; i++) {
    int kol = i / 7;
    int bar = i % 7;
    float x = x0 + kol * (lebarBaris + gap);
    float y = y0 + bar * (tinggiBaris + 6);
    boolean buka = pencapaianBuka[i];

    noStroke();
    fill(0, 0, 0, 40);
    rect(x + 3, y + 4, lebarBaris, tinggiBaris, 12);
    fill(buka ? color(255, 250, 215) : color(240, 242, 235));
    rect(x, y, lebarBaris, tinggiBaris, 12);
    noFill();
    stroke(buka ? color(230, 165, 20) : color(170, 185, 170));
    strokeWeight(buka ? 2.5 : 1.5);
    rect(x, y, lebarBaris, tinggiBaris, 12);
    noStroke();

    gambarPiala(x + 34, y + tinggiBaris / 2, 0.85, buka);

    textAlign(LEFT, CENTER);
    fill(buka ? color(35, 85, 45) : color(110, 125, 110));
    textSize(15);
    text(prNama[i], x + 66, y + 20);
    fill(buka ? color(90, 110, 90) : color(130, 140, 130));
    textSize(12);
    text(prDesk[i], x + 66, y + 42);

    // Sisi kanan: hadiah atau progres.
    textAlign(RIGHT, CENTER);
    if (buka) {
      fill(180, 120, 10);
      textSize(13);
      text("+" + prHadiah[i] + " KOIN", x + lebarBaris - 14, y + 31);
    } else {
      int nilai = nilaiPrestasi(i);
      if (nilai >= 0 && prTarget[i] > 0) {
        float p = constrain(nilai / (float) prTarget[i], 0, 1);
        float bw = 86, bx = x + lebarBaris - 14 - bw, by = y + 40;
        fill(210, 220, 205);
        rect(bx, by, bw, 8, 4);
        fill(cyan);
        rect(bx, by, bw * p, 8, 4);
        fill(110, 125, 110);
        textSize(11);
        text(min(nilai, prTarget[i]) + "/" + prTarget[i], x + lebarBaris - 14, y + 22);
      } else {
        fill(160, 150, 100);
        textSize(12);
        text("+" + prHadiah[i] + " KOIN", x + lebarBaris - 14, y + 31);
      }
    }
  }

  btnKembali.display();
}

// ---------- LAYAR TOKO SKIN ----------
final float KARTU_Y = 135, KARTU_W = 156, KARTU_H = 400;
String pesanToko = "";
int pesanTokoWaktu = 0;

float kartuSkinX(int i) {
  float total = JUMLAH_SKIN * KARTU_W + (JUMLAH_SKIN - 1) * 14;
  return (VW - total) / 2 + i * (KARTU_W + 14);
}

boolean tombolSkinHover(int i) {
  float x = kartuSkinX(i) + 16, y = KARTU_Y + 340;
  return mx() >= x && mx() <= x + KARTU_W - 32 && my() >= y && my() <= y + 42;
}

// Lencana kecil berisi jumlah koin dompet (dipakai di menu dan toko).
void lencanaKoin(float xTengah, float y) {
  String t = "KOIN  " + dompet;
  textSize(16);
  textAlign(LEFT, CENTER);
  float w = textWidth(t) + 62;
  float xl = xTengah - w / 2;
  noStroke();
  fill(255, 255, 235, 235);
  rect(xl, y - 17, w, 34, 17);
  fill(200, 140, 10);
  ellipse(xl + 22, y, 22, 22);
  fill(255, 205, 35);
  ellipse(xl + 22, y, 17, 17);
  fill(255, 245, 170);
  ellipse(xl + 19, y - 3, 6, 6);
  fill(180, 130, 20);
  text(t, xl + 40, y - 1);
}

void gambarToko() {
  latarMenu();

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(36);
  text("TOKO SKIN", VW / 2, 42);
  lencanaKoin(VW / 2, 90);

  for (int i = 0; i < JUMLAH_SKIN; i++) {
    float x = kartuSkinX(i), y = KARTU_Y;
    boolean pakai = (skinAktif == i);
    boolean milik = skinMilik[i];
    boolean bisaBeli = !milik && dompet >= skinHarga[i];
    boolean hv = tombolSkinHover(i);

    noStroke();
    fill(0, 0, 0, 50);
    rect(x + 4, y + 6, KARTU_W, KARTU_H, 16);
    fill(pakai ? color(232, 255, 225) : color(255, 255, 245));
    rect(x, y, KARTU_W, KARTU_H, 16);
    noFill();
    stroke(pakai ? cyan : color(120, 170, 120));
    strokeWeight(pakai ? 3 : 1.5);
    rect(x, y, KARTU_W, KARTU_H, 16);

    // Pratinjau bola yang berputar.
    float cx = x + KARTU_W / 2, cy = y + 100;
    noStroke();
    fill(skinTengah[i], 35);
    ellipse(cx, cy, 120, 120);
    fill(0, 0, 0, 40);
    ellipse(cx, cy + 56, 70, 10);
    pushMatrix();
    translate(cx, cy);
    bola3D(0, 0, 38, i, waktuAnimasi * 2);
    popMatrix();

    fill(35, 85, 45);
    textAlign(CENTER, CENTER);
    textSize(19);
    text(skinNama[i], cx, y + 190);
    fill(90, 110, 90);
    textSize(12);
    text(skinDesk[i], cx, y + 214);

    // Harga / status.
    textSize(14);
    if (pakai) {
      fill(40, 150, 60);
      text("SEDANG DIPAKAI", cx, y + 262);
    } else if (milik) {
      fill(40, 150, 60);
      text("DIMILIKI", cx, y + 262);
    } else if (skinHarga[i] == 0) {
      fill(40, 150, 60);
      text("GRATIS", cx, y + 262);
    } else {
      fill(180, 130, 20);
      text(skinHarga[i] + " KOIN", cx, y + 262);
    }

    // Tombol aksi.
    float bx = x + 16, by = y + 340, bw = KARTU_W - 32, bh = 42;
    String label;
    color warna;
    if (pakai) {
      label = "DIPAKAI";
      warna = color(170, 190, 170);
    } else if (milik) {
      label = "PAKAI";
      warna = cyan;
    } else {
      label = "BELI";
      warna = bisaBeli ? color(230, 160, 20) : color(190, 160, 160);
    }
    noStroke();
    fill(hv && !pakai ? warna : color(255, 255, 235));
    rect(bx, by, bw, bh, 10);
    noFill();
    stroke(warna);
    strokeWeight(hv && !pakai ? 2.5 : 1.5);
    rect(bx, by, bw, bh, 10);
    noStroke();
    fill(35, 85, 45);
    textSize(15);
    textAlign(CENTER, CENTER);
    text(label, bx + bw / 2, by + bh / 2);
  }

  if (pesanTokoWaktu > 0) {
    pesanTokoWaktu--;
    fill(35, 85, 45);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(pesanToko, VW / 2, 556);
  } else {
    fill(40, 100, 55);
    textAlign(CENTER, CENTER);
    textSize(13);
    text("Kumpulkan koin di level dan selesaikan pencapaian untuk membeli skin baru.", VW / 2, 556);
  }

  btnKembali.display();
}

// Aksi tombol kartu: beli skin, atau pakai skin yang sudah dimiliki.
void aksiSkin(int i) {
  if (skinAktif == i) return;
  if (skinMilik[i]) {
    skinAktif = i;
    klik();
    pesanToko = "Skin " + skinNama[i] + " dipakai!";
    pesanTokoWaktu = 120;
    simpanData();
  } else if (dompet >= skinHarga[i]) {
    boolean pertama = (jumlahSkinDimiliki() == 1);
    dompet -= skinHarga[i];
    skinMilik[i] = true;
    skinAktif = i;
    mainkanSfx(sfxBeli);
    pesanToko = "Berhasil membeli skin " + skinNama[i] + "!";
    pesanTokoWaktu = 150;
    simpanData();
    if (pertama) bukaPrestasi(12);
    if (jumlahSkinDimiliki() >= JUMLAH_SKIN) bukaPrestasi(13);
  } else {
    klik();
    pesanToko = "Koin belum cukup, kurang " + (skinHarga[i] - dompet) + " koin lagi.";
    pesanTokoWaktu = 150;
  }
}

// ---------- HITBOX (tombol B) & CHECKPOINT PRACTICE ----------
// Menggambar semua hitbox pada koordinat fisika yang sebenarnya dipakai untuk tabrakan.
void gambarHitbox() {
  hint(DISABLE_DEPTH_TEST);
  noFill();
  strokeWeight(2);

  stroke(255, 255, 255, 200); // platform
  for (Platform p : platforms) rect(p.x, p.y, p.w, p.h);

  stroke(255, 140, 0); // duri (segitiga)
  for (Spike s : spikes) triangle(s.x, s.y, s.x + 12, s.y + 27 * s.arah, s.x + 24, s.y);

  if (!modePractice) { // koin
    stroke(255, 230, 60);
    for (Coin c : coins) if (!c.terambil) ellipse(c.x, c.y, c.rKini() * c.skalaX() * 2, c.rKini() * 2);
  }

  stroke(60, 255, 90); // badan bola (platform, koin, duri: semuanya memakai lingkaran yang sama dengan gambar bola)
  ellipse(player.x, player.y, player.r * 2, player.r * 2);
  noStroke();
}

void gambarLegendaHitbox() {
  float x = 15, y = VH - 96;
  noStroke();
  fill(0, 0, 0, 170);
  rect(x, y, 300, 81, 9);
  textAlign(LEFT, CENTER);
  textSize(12);
  String[] ket = {"Bola (platform, koin, duri)", "Koin (elips sesuai putaran)", "Duri", "Platform"};
  color[] war = {color(60, 255, 90), color(255, 230, 60), color(255, 140, 0), color(255)};
  for (int i = 0; i < ket.length; i++) {
    fill(war[i]);
    rect(x + 12, y + 12 + i * 17, 14, 4, 2);
    fill(255);
    text(ket[i], x + 36, y + 14 + i * 17);
  }
}

// Penanda checkpoint buatan di practice mode (berlian hijau seperti Geometry Dash).
void gambarCheckpointPractice() {
  if (!modePractice || !practiceCpAda) return;
  float k = 1 + sin(waktuAnimasi * 4) * 0.08;
  pushMatrix();
  translate(practiceCpX, practiceCpY - 6);
  scale(k);
  noStroke();
  fill(60, 255, 120, 60);
  ellipse(0, 0, 54, 54);
  fill(40, 200, 90);
  quad(0, -20, 14, 0, 0, 20, -14, 0);
  fill(170, 255, 200);
  quad(0, -12, 7, 0, 0, 12, -7, 0);
  popMatrix();
}
