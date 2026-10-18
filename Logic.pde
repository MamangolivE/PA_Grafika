// =====================================================
// LOGIKA GAME
//   Berisi: alur level/state, class objek (Level, Platform, Spike, Coin, Player, Particle),
//   fisika & tabrakan, checkpoint/nyawa/kemenangan, dan input mouse/keyboard.
// =====================================================

// Fungsi ubahState: Mengganti state game, mereset animasi popup dan input.
void ubahState(int s) {
  gameState = s;
  popupAnim = 0;
  resetInput();
}

// Fungsi mulaiGameBaru: Memulai permainan baru dari level l dengan nyawa, skor, dan koin direset.
void mulaiGameBaru(int l) {
  nyawa = 3;
  skor = 0;
  jumlahKoin = 0;
  mulaiLevelBaru(l);
}

// Fungsi mulaiLevelBaru: Menyiapkan level l: ambil data level, reset penghitung loading, lalu masuk state LOADING.
void mulaiLevelBaru(int l) {
  level = l;
  lv = infoLevel(l);
  skorAwalLevel = skor;
  koinAwalLevel = jumlahKoin;
  loadTimer = 0;
  levelDibuat = false;
  audioSiap = false;
  hentikanBgm();
  ubahState(LOADING);
}

// Fungsi ulangLevel: Mengulang level saat game over (skor dikembalikan ke awal level).
void ulangLevel() {
  skor = skorAwalLevel;
  jumlahKoin = koinAwalLevel;
  nyawa = 3;
  mulaiLevelBaru(level);
}

// Fungsi keMenu: Kembali ke menu utama dan memutar musik menu.
void keMenu() {
  mainkanBgm(0);
  ubahState(MENU);
}

// Fungsi bukaAturan: Membuka popup aturan, mengingat state asal agar bisa kembali.
void bukaAturan(int kembaliKe) {
  stateSebelumRules = kembaliKe;
  ubahState(RULES);
}

// Fungsi tutupAturan: Menutup popup aturan dan kembali ke state sebelumnya.
void tutupAturan() {
  ubahState(stateSebelumRules);
}

// Fungsi buatLevel: Mengosongkan semua daftar objek lalu membangun level aktif, membuat cuaca dan pemain.
void buatLevel() {
  platforms.clear();
  spikes.clear();
  coins.clear();
  particles.clear();

  cameraX = 0;
  checkpointX = 80;
  checkpointAktif = false;

  // switch: bangun level sesuai nomor level.
  switch (level) {
  case 1:
    bangunLevel1();
    break;
  case 2:
    bangunLevel2();
    break;
  case 3:
    bangunLevel3();
    break;
  default:
    bangunLevel4();
    break;
  }

  cuaca = new EfekCuaca(lv.tipeCuaca);
  player = new Player(100, 490);
}

// Konstanta jenis cuaca.
final int C_NONE = 0, C_HUJAN = 1, C_SALJU = 2, C_ES = 3, C_GOA = 4;

// ----- CLASS Level: wadah data satu level (nama, aturan, ukuran dunia, licin, cuaca, warna). -----
class Level {
  int id;
  String nama = "";
  String tujuan = "";
  String tip = "";
  String[] aturan = new String[0];

  float lebar = 3000;
  float cpX = 1000;
  float cpY = 560;
  float exitY = 510;
  float traksi = 1.0;
  boolean gelap = false;
  int tipeCuaca = C_NONE;
  int indexBgm = 1;

  color cTanah = color(150, 100, 50);
  color cAtas = color(60, 170, 60);
  color cAmbient = color(120, 120, 120);
  color cSinar = color(220, 220, 220);
  color langitA = color(100, 180, 255);
  color langitB = color(200, 230, 255);
}

// Fungsi infoLevel: Mengembalikan data Level sesuai nomor level.
Level infoLevel(int id) {
  // switch: pilih data level.
  switch (id) {
  case 1:
    return infoLevel1();
  case 2:
    return infoLevel2();
  case 3:
    return infoLevel3();
  default:
    return infoLevel4();
  }
}

// Fungsi tambahDuri: Menambah deretan duri lantai ke daftar spikes.
void tambahDuri(float x, float y, int jumlah) {
  // Perulangan for: tambah duri berjajar ke kanan.
  for (int i = 0; i < jumlah; i++) {
    spikes.add(new Spike(x + i * 24, y, -1));
  }
}

// Fungsi tambahStalaktit: Menambah deretan stalaktit menggantung ke daftar spikes.
void tambahStalaktit(float x, float y, int jumlah) {
  // Perulangan for: tambah stalaktit berjajar ke kanan.
  for (int i = 0; i < jumlah; i++) {
    spikes.add(new Spike(x + i * 24, y, 1));
  }
}

// Fungsi tambahKoin: Menambah satu koin ke daftar coins.
void tambahKoin(float x, float y) {
  coins.add(new Coin(x, y));
}

// Fungsi barisKoin: Menambah sebaris koin dengan jarak tetap.
void barisKoin(float x, float y, int jumlah, float jarak) {
  // Perulangan for: tambah koin berjajar dengan jarak tetap.
  for (int i = 0; i < jumlah; i++) {
    tambahKoin(x + i * jarak, y);
  }
}

// ----- CLASS Platform: pijakan 3D (box) dengan posisi, ukuran, dan tingkat licin. -----
class Platform {
  float x, y, w, h;
  float dx = 0;
  float traksi;

  // Konstruktor Platform: simpan posisi/ukuran dan ambil traksi dari level.
  Platform(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    traksi = lv.traksi;
  }

  // Kosong pada platform biasa; di-override oleh MovingPlatform (polymorphism).
  void update() {
  }

  // Menggambar platform: badan tanah, lapisan atas, dan kilau tipis memakai box.
  void display() {
    noStroke();

    pushMatrix();
    translate(x + w / 2, y + h / 2, 0);
    fill(lv.cTanah);
    box(w, h, 56);
    popMatrix();

    pushMatrix();
    translate(x + w / 2, y + 5, 0);
    fill(lv.cAtas);
    box(w + 2, 10, 60);
    popMatrix();

    pushMatrix();
    translate(x + w / 2, y + 1.5, 31);
    fill(lerpColor(lv.cAtas, color(255), 0.45));
    box(w, 3, 2);
    popMatrix();
  }
}

// ----- CLASS MovingPlatform (turunan Platform): platform yang bergerak kiri-kanan memakai sin (inheritance). -----
class MovingPlatform extends Platform {
  float x0, jarak, kecepatan;
  float fase = 0;

  // Konstruktor: panggil super lalu simpan jarak dan kecepatan gerak.
  MovingPlatform(float x, float y, float w, float h, float jarak, float kecepatan) {
    super(x, y, w, h);
    this.x0 = x;
    this.jarak = jarak;
    this.kecepatan = kecepatan;
  }

  // Menghitung posisi baru dengan sin dan menyimpan selisihnya (dx) agar pemain ikut terbawa.
  void update() {
    fase += 0.04 * kecepatan;
    // Posisi baru platform bergerak berdasarkan gelombang sin.
    float xBaru = x0 + (sin(fase) * 0.5 + 0.5) * jarak;
    dx = xBaru - x;
    x = xBaru;
  }

  // Menggambar platform biasa ditambah garis kuning penanda platform bergerak.
  void display() {
    super.display();

    pushMatrix();
    translate(x + w / 2, y + h + 2, 0);
    fill(255, 215, 60);
    box(w * 0.6, 4, 30);
    popMatrix();
  }
}

// ----- CLASS Spike: duri lantai atau stalaktit berbentuk piramida; arah -1 = ke atas, 1 = menggantung. -----
class Spike {
  float x, y;
  int arah;

  // Konstruktor Spike: posisi dan arah.
  Spike(float x, float y, int arah) {
    this.x = x;
    this.y = y;
    this.arah = arah;
  }

  // Warna duri sesuai level (switch).
  color warna() {
    // switch: warna duri tiap level.
    switch (lv.id) {
    case 1:
      return color(225, 65, 50);
    case 2:
      return color(125, 160, 205);
    case 3:
      return color(150, 225, 255);
    default:
      return color(150, 125, 185);
    }
  }

  // Menggambar piramida dari 4 segitiga dengan warna sisi berbeda agar terlihat 3D.
  void display() {
    noStroke();
    color c = warna();
    float ay = y + 27 * arah;
    float xm = x + 12;

    beginShape(TRIANGLES);
    fill(c);
    vertex(x, y, 14);
    vertex(x + 24, y, 14);
    vertex(xm, ay, 0);

    fill(lerpColor(c, color(0), 0.35));
    vertex(x + 24, y, 14);
    vertex(x + 24, y, -14);
    vertex(xm, ay, 0);

    fill(lerpColor(c, color(0), 0.5));
    vertex(x + 24, y, -14);
    vertex(x, y, -14);
    vertex(xm, ay, 0);

    fill(lerpColor(c, color(0), 0.2));
    vertex(x, y, -14);
    vertex(x, y, 14);
    vertex(xm, ay, 0);
    endShape();
  }
}

// ----- CLASS Coin: koin yang bisa diambil; tampil berdenyut dan berputar. -----
class Coin {
  float x, y;
  boolean terambil = false;

  // Konstruktor Coin: posisi koin.
  Coin(float x, float y) {
    this.x = x;
    this.y = y;
  }

  // Menggambar koin dari ellipse; scale horizontal berubah-ubah agar tampak berputar.
  void display() {
    if (terambil) return;

    // Ukuran koin berdenyut dengan sin.
    float ukuran = 18 + sin(waktuAnimasi * 3 + x) * 2;

    pushMatrix();
    translate(x, y);
    noStroke();
    fill(255, 225, 80, 70);
    ellipse(0, 0, ukuran * 2.2, ukuran * 2.2);

    // Lebar koin mengecil-membesar sehingga terlihat berputar.
    scale(max(0.18, abs(cos(waktuAnimasi * 2 + x * 0.01))), 1);
    fill(200, 140, 10);
    ellipse(0, 0, ukuran + 4, ukuran + 4);
    fill(255, 205, 35);
    ellipse(0, 0, ukuran, ukuran);
    fill(255, 245, 170);
    ellipse(-3, -3, ukuran * 0.35, ukuran * 0.35);
    popMatrix();
  }
}

// ----- CLASS Player: bola pemain (fisika gerak, gravitasi, lompat, tabrakan platform). -----
class Player {
  float x, y;
  float vx = 0;
  float vy = 0;
  float r = 18;
  float kecepatan = 4.5;
  float gravitasi = 0.48;
  float kekuatanLompat = -10.5;
  float putar = 0;

  boolean diTanah = false;
  Platform berdiri = null;

  // Konstruktor Player: posisi awal.
  Player(float xAwal, float yAwal) {
    x = xAwal;
    y = yAwal;
  }

  // Fisika pemain per frame: gerak horizontal dengan traksi, lompat, gravitasi, dan tabrakan dengan platform.
  void update() {
    // Kecepatan tujuan dari tombol kiri/kanan.
    float target = 0;
    if (tombolKiri && !tombolKanan) target = -kecepatan;
    else if (tombolKanan && !tombolKiri) target = kecepatan;

    // Pilih tingkat traksi: dari platform jika menapak, dari level jika di udara.
    float g;
    if (diTanah && berdiri != null) g = berdiri.traksi;
    else g = constrain(lv.traksi * 1.6, 0.18, 1);

    // Traksi: makin kecil g makin licin (kecepatan menuju target pelan-pelan).
    vx += (target - vx) * g;
    if (abs(vx) < 0.05) vx = 0;

    // Lompat hanya jika ada permintaan dan bola menapak.
    if (permintaanLompat) {
      if (diTanah) lompat();
      permintaanLompat = false;
    }

    x += vx;

    float yLama = y;
    // Gravitasi menambah kecepatan jatuh tiap frame.
    vy += gravitasi;
    vy = min(vy, 12);
    y += vy;

    // Reset status menapak; dihitung ulang lewat tabrakan di bawah.
    diTanah = false;
    berdiri = null;

    // Perulangan for-each: cek tabrakan bola dengan setiap platform.
    for (Platform p : platforms) {
      boolean masuk = x + r > p.x && x - r < p.x + p.w;
      // Pendaratan: bola dari atas menyentuh permukaan platform.
      if (masuk && yLama + r <= p.y + 1 && y + r >= p.y && vy >= 0) {
        y = p.y - r;
        vy = 0;
        diTanah = true;
        berdiri = p;
      }
    }

    // Ikut terbawa platform yang sedang bergerak.
    if (berdiri != null) x += berdiri.dx;
    x = constrain(x, r, lv.lebar - r);
    putar += vx / r;
  }

  // Membuat bola melompat dan mengeluarkan partikel serta suara.
  void lompat() {
    if (diTanah && gameState == PLAY) {
      vy = kekuatanLompat;
      diTanah = false;
      mainkanSfx(sfxLompat);
      // Perulangan for: keluarkan 5 partikel debu.
      for (int i = 0; i < 5; i++) {
        particles.add(new Particle(x, y + r, cyan));
      }
    }
  }

  // Menggambar bola dari ellipse bertumpuk, dengan squash-stretch dan bintik yang berputar.
  void display() {
    pushMatrix();
    translate(x, y);

    float s = 1 + constrain(vy * 0.012, -0.12, 0.12);
    // Squash & stretch: bola memanjang saat jatuh/naik (transformasi scale).
    scale(1 / s, s);

    noStroke();
    if (lv.gelap) {
      fill(255, 200, 120, 40);
      ellipse(0, 0, r * 5, r * 5);
      fill(255, 200, 120, 60);
      ellipse(0, 0, r * 3.2, r * 3.2);
    }

    // Badan bola: lapisan tepi gelap, warna utama, lalu kilau.
    fill(120, 15, 15);
    ellipse(0, 0, r * 2 + 4, r * 2 + 4);
    fill(195, 35, 35);
    ellipse(0, 0, r * 2, r * 2);
    fill(235, 55, 45);
    ellipse(-2, -2, r * 1.72, r * 1.72);

    // Putar bintik agar terlihat menggelinding (transformasi rotate).
    rotate(putar);
    fill(255, 190, 160);
    ellipse(r * 0.5, -r * 0.35, r * 0.4, r * 0.4);
    fill(255, 255, 255, 200);
    ellipse(-r * 0.45, r * 0.4, r * 0.22, r * 0.22);

    popMatrix();
  }
}

// ----- CLASS Particle: partikel kecil efek koin, lompat, dan terkena duri. -----
class Particle {
  float x, y;
  float vx, vy;
  float umur = 30;
  color warna;

  // Konstruktor Particle: posisi, warna, dan kecepatan acak.
  Particle(float x, float y, color warna) {
    this.x = x;
    this.y = y;
    this.warna = warna;
    vx = random(-2.5, 2.5);
    vy = random(-3.5, 0.5);
  }

  // Gerak partikel dengan gravitasi dan umur berkurang.
  void update() {
    x += vx;
    y += vy;
    vy += 0.12;
    umur--;
  }

  // Menggambar partikel yang mengecil dan memudar sesuai umur.
  void display() {
    noStroke();
    fill(warna, map(umur, 0, 30, 0, 255));
    ellipse(x, y, map(umur, 0, 30, 1, 7), map(umur, 0, 30, 1, 7));
  }
}

// Fungsi updateGame: Update satu frame gameplay: platform, pemain, pemeriksaan tabrakan, kamera, partikel, dan petir.
void updateGame() {
  // Perulangan for-each: update semua platform.
  for (Platform p : platforms) {
    p.update();
  }

  player.update();

  periksaKoin();
  periksaDuri();
  if (gameState != PLAY) return;
  periksaCheckpoint();
  periksaKemenangan();
  if (gameState != PLAY) return;

  // Jatuh ke jurang = kehilangan nyawa.
  if (player.y > height + 100) {
    kehilanganNyawa();
  }

  float targetCam = player.x - width * 0.38;
  // Kamera mengikuti pemain dengan halus (lerp) dan dibatasi tepi level.
  cameraX = constrain(lerp(cameraX, targetCam, 0.2), 0, lv.lebar - width);

  // Perulangan for (mundur): update partikel dan hapus yang sudah habis umurnya.
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (p.umur <= 0) {
      particles.remove(i);
    }
  }

  // Petir acak hanya di level hujan.
  if (lv.id == 1 && random(1) < 0.0025) {
    kilat = 1;
  }
  // Kilatan petir memudar tiap frame.
  kilat *= 0.92;
}

// Fungsi periksaKoin: Memeriksa apakah bola menyentuh koin; jika ya tambah skor, suara, dan partikel.
void periksaKoin() {
  // Perulangan for-each: cek jarak bola ke setiap koin.
  for (Coin c : coins) {
    // Koin diambil jika belum diambil dan jarak ke bola kurang dari 30.
    if (!c.terambil && dist(player.x, player.y, c.x, c.y) < 30) {
      c.terambil = true;
      skor += 100;
      jumlahKoin++;
      mainkanSfx(sfxKoin);
      // Perulangan for: keluarkan 8 partikel.
      for (int i = 0; i < 8; i++) {
        particles.add(new Particle(c.x, c.y, color(255, 205, 65)));
      }
    }
  }
}

// Fungsi periksaDuri: Memeriksa tabrakan bola dengan semua duri.
void periksaDuri() {
  // Perulangan for-each: cek tabrakan dengan setiap duri.
  for (Spike s : spikes) {
    if (bolaMenyentuhSegitiga(
      player.x, player.y, player.r * 0.9,
      s.x, s.y,
      s.x + 12, s.y + 27 * s.arah,
      s.x + 24, s.y)) {
      kehilanganNyawa();
      return;
    }
  }
}

// Fungsi bolaMenyentuhSegitiga: Tabrakan lingkaran-segitiga: titik di dalam segitiga atau jarak ke sisi kurang dari radius.
boolean bolaMenyentuhSegitiga(float cx, float cy, float r,
  float x1, float y1, float x2, float y2, float x3, float y3) {
  if (titikDalamSegitiga(cx, cy, x1, y1, x2, y2, x3, y3)) return true;
  if (jarakTitikKeGaris(cx, cy, x1, y1, x2, y2) <= r ||
      jarakTitikKeGaris(cx, cy, x2, y2, x3, y3) <= r ||
      jarakTitikKeGaris(cx, cy, x3, y3, x1, y1) <= r) return true;
  return false;
}

// Fungsi titikDalamSegitiga: Menguji apakah titik berada di dalam segitiga (tanda hasil kali silang).
boolean titikDalamSegitiga(float px, float py, float x1, float y1,
  float x2, float y2, float x3, float y3) {
  float d1 = (px - x2) * (y1 - y2) - (x1 - x2) * (py - y2);
  float d2 = (px - x3) * (y2 - y3) - (x2 - x3) * (py - y3);
  float d3 = (px - x1) * (y3 - y1) - (x3 - x1) * (py - y1);
  boolean negatif = d1 < 0 || d2 < 0 || d3 < 0;
  boolean positif = d1 > 0 || d2 > 0 || d3 > 0;
  return !(negatif && positif);
}

// Fungsi jarakTitikKeGaris: Jarak terdekat dari titik ke sebuah ruas garis.
float jarakTitikKeGaris(float px, float py, float x1, float y1, float x2, float y2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  // Proyeksi titik ke garis, dibatasi di dalam ruas (constrain).
  float pk = dx * dx + dy * dy;
  if (pk == 0) return dist(px, py, x1, y1);
  float t = constrain(((px - x1) * dx + (py - y1) * dy) / pk, 0, 1);
  return dist(px, py, x1 + t * dx, y1 + t * dy);
}

// Fungsi periksaCheckpoint: Mengaktifkan checkpoint saat bola melewati bendera (+250 skor).
void periksaCheckpoint() {
  // Checkpoint aktif sekali saat bola melewati bendera.
  if (player.x > lv.cpX && !checkpointAktif) {
    checkpointAktif = true;
    checkpointX = lv.cpX;
    skor += 250;
    mainkanSfx(sfxCheckpoint);
    // Perulangan for: keluarkan 18 partikel perayaan.
    for (int i = 0; i < 18; i++) {
      particles.add(new Particle(lv.cpX, lv.cpY - 60, color(255, 220, 40)));
    }
  }
}

// Fungsi periksaKemenangan: Mengecek apakah bola mencapai portal; lanjut ke popup level selesai atau tamat.
void periksaKemenangan() {
  // Menang bila bola sudah dekat portal di ujung level.
  if (player.x >= lv.lebar - 120) {
    skor += 500;
    mainkanSfx(sfxMenang);
    if (level < JUMLAH_LEVEL) {
      ubahState(LEVEL_DONE);
    } else {
      ubahState(WIN);
    }
  }
}

// Fungsi kehilanganNyawa: Mengurangi nyawa; respawn di checkpoint atau game over jika nyawa habis.
void kehilanganNyawa() {
  nyawa--;
  mainkanSfx(sfxKena);
  // Perulangan for: keluarkan 14 partikel merah.
  for (int i = 0; i < 14; i++) {
    particles.add(new Particle(player.x, player.y, color(235, 55, 45)));
  }
  resetInput();

  // Nyawa habis = game over, jika belum respawn di checkpoint.
  if (nyawa <= 0) {
    ubahState(LOSE);
  } else {
    player = new Player(checkpointX + 30, lv.cpY - 90);
    cameraX = max(0, checkpointX - 300);
  }
}

// Fungsi mousePressed: Event klik mouse: tombol dan kartu sesuai gameState.
void mousePressed() {
  // switch: aksi klik sesuai state game.
  switch (gameState) {
  case MENU:
    if (btnMulai.hover()) {
      klik();
      mulaiGameBaru(1);
    } else if (btnPilih.hover()) {
      klik();
      ubahState(PILIH);
    } else if (btnPetunjuk.hover()) {
      klik();
      ubahState(HELP);
    } else {
      sliderMenu.tekan();
    }
    break;

  case PILIH:
    // Perulangan for: cek klik pada tiap kartu level.
    for (int i = 1; i <= JUMLAH_LEVEL; i++) {
      if (kartuHover(i)) {
        klik();
        mulaiGameBaru(i);
        return;
      }
    }
    if (btnKembali.hover()) {
      klik();
      ubahState(MENU);
    }
    break;

  case HELP:
    if (btnKembali.hover()) {
      klik();
      ubahState(MENU);
    }
    break;

  case RULES:
    if (btnMulaiAturan.hover()) {
      klik();
      tutupAturan();
    }
    break;

  case PAUSE:
    if (btnLanjut.hover()) {
      klik();
      ubahState(PLAY);
    } else if (btnAturan.hover()) {
      klik();
      bukaAturan(PAUSE);
    } else if (btnMenuPause.hover()) {
      klik();
      keMenu();
    } else {
      sliderPause.tekan();
    }
    break;

  case LEVEL_DONE:
  case WIN:
  case LOSE:
    if (btnAksi1.hover()) {
      klik();
      aksiUtama();
    } else if (btnAksi2.hover()) {
      klik();
      keMenu();
    }
    break;
  }
}

// Fungsi mouseDragged: Event mouse digeser: mengubah volume saat slider diseret.
void mouseDragged() {
  if (sliderMenu.drag || sliderPause.drag) {
    if (gameState == MENU) sliderMenu.ubah();
    if (gameState == PAUSE) sliderPause.ubah();
  }
}

// Fungsi mouseReleased: Event mouse dilepas: berhenti menyeret slider.
void mouseReleased() {
  sliderMenu.drag = false;
  sliderPause.drag = false;
}

// Fungsi aksiUtama: Aksi tombol utama pada popup selesai/tamat/kalah.
void aksiUtama() {
  if (gameState == LEVEL_DONE) mulaiLevelBaru(level + 1);
  else if (gameState == WIN) mulaiGameBaru(1);
  else if (gameState == LOSE) ulangLevel();
}

// Fungsi keyPressed: Event tombol ditekan: ESC/P pause, M mute, H aturan, ENTER/SPASI konfirmasi, A/D gerak, SPASI lompat.
void keyPressed() {
  // Tombol ESC: pause / lanjut / tutup aturan.
  if (key == ESC) {
    key = 0;
    if (gameState == PLAY) ubahState(PAUSE);
    else if (gameState == PAUSE) ubahState(PLAY);
    else if (gameState == RULES) tutupAturan();
    return;
  }

  if (key == 'm' || key == 'M') {
    senyap = !senyap;
    terapkanVolume();
    return;
  }

  if (gameState == RULES) {
    if (key == ENTER || key == RETURN || key == ' ') tutupAturan();
    return;
  }

  if (gameState == LEVEL_DONE || gameState == WIN || gameState == LOSE) {
    if (key == ENTER || key == RETURN) aksiUtama();
    return;
  }

  if (gameState == PAUSE) {
    if (key == 'p' || key == 'P') ubahState(PLAY);
    return;
  }

  if (gameState != PLAY) return;

  if (key == 'a' || key == 'A' || keyCode == LEFT) tombolKiri = true;
  if (key == 'd' || key == 'D' || keyCode == RIGHT) tombolKanan = true;

  if (key == ' ' || key == 'w' || key == 'W' || keyCode == UP) {
    if (!tombolLompat) {
      tombolLompat = true;
      permintaanLompat = true;
    }
  }

  if (key == 'p' || key == 'P') ubahState(PAUSE);
  if (key == 'h' || key == 'H') bukaAturan(PLAY);
}

// Fungsi keyReleased: Event tombol dilepas: hentikan gerak.
void keyReleased() {
  if (key == 'a' || key == 'A' || keyCode == LEFT) tombolKiri = false;
  if (key == 'd' || key == 'D' || keyCode == RIGHT) tombolKanan = false;
  if (key == ' ' || key == 'w' || key == 'W' || keyCode == UP) tombolLompat = false;
}

// Fungsi resetInput: Mengosongkan semua status tombol agar bola tidak bergerak sendiri.
void resetInput() {
  tombolKiri = false;
  tombolKanan = false;
  tombolLompat = false;
  permintaanLompat = false;
}

