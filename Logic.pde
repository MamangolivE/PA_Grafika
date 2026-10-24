// =====================================================
// LOGIKA UTAMA GAME
// Berisi pengaturan alur state, class objek (Level, Platform, Spike, Coin, Player, Particle),
// serta fungsi fisika, deteksi tabrakan (collision), dan kontrol input.
// =====================================================

// Fungsi untuk mengganti state game dan reset input tombol agar tidak tersangkut
void ubahState(int s) {
  gameState = s;
  popupAnim = 0;
  resetInput();
}

// Fungsi untuk memulai game baru dari awal
void mulaiGameBaru(int l) {
  nyawa = 3;
  skor = 0;
  jumlahKoin = 0;
  mulaiLevelBaru(l);
}

// Persiapan sebelum memuat level, termasuk mengatur layar loading
void mulaiLevelBaru(int l) {
  level = l;
  lv = infoLevel(l);
  skorAwalLevel = skor;
  koinAwalLevel = jumlahKoin;
  matiDiLevel = 0;
  loadTimer = 0;
  levelDibuat = false;
  audioSiap = false;
  hentikanBgm();
  ubahState(LOADING);
}

// Mengembalikan skor dan koin ke kondisi awal level jika pemain mati (game over)
void ulangLevel() {
  skor = skorAwalLevel;
  jumlahKoin = koinAwalLevel;
  nyawa = 3;
  mulaiLevelBaru(level);
}

// Fungsi untuk kembali ke menu utama dan memutar musik menu
void keMenu() {
  simpanData();
  mainkanBgm(0);
  ubahState(MENU);
}

// Membuka popup aturan level dan menyimpan state sebelumnya agar bisa kembali
void bukaAturan(int kembaliKe) {
  stateSebelumRules = kembaliKe;
  ubahState(RULES);
}

// Menutup popup aturan dan kembali ke state game terakhir
void tutupAturan() {
  ubahState(stateSebelumRules);
}

// Fungsi untuk membersihkan semua objek lama dan membangun ulang arena level yang baru
void buatLevel() {
  platforms.clear();
  spikes.clear();
  coins.clear();
  particles.clear();

  cameraX = 0;
  checkpointX = 80;
  checkpointAktif = false;
  practiceCpAda = false;

  // Load layout objek sesuai dengan nomor level yang aktif
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
  case 4:
    bangunLevel4();
    break;
  default:
    bangunLevel5(); 
    break;
  }

  // Buat objek cuaca dan tempatkan pemain di titik awal
  cuaca = new EfekCuaca(lv.tipeCuaca);
  player = new Player(100, 490);
}

// Konstanta untuk tipe cuaca
final int C_NONE = 0, C_HUJAN = 1, C_SALJU = 2, C_ES = 3, C_GOA = 4;

// Class untuk menyimpan data konfigurasi dan settingan dari tiap level
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

// Fungsi untuk mengambil data level berdasarkan nomor levelnya
Level infoLevel(int id) {
  switch (id) {
  case 1:
    return infoLevel1();
  case 2:
    return infoLevel2();
  case 3:
    return infoLevel3();
  case 4:
    return infoLevel4();
  default:
    return infoLevel5(); 
  }
}

// Fungsi untuk menambahkan duri secara berjejer di lantai
void tambahDuri(float x, float y, int jumlah) {
  for (int i = 0; i < jumlah; i++) {
    spikes.add(new Spike(x + i * 24, y, -1));
  }
}

// Fungsi untuk menambahkan duri menggantung (stalaktit) secara berjejer
void tambahStalaktit(float x, float y, int jumlah) {
  for (int i = 0; i < jumlah; i++) {
    spikes.add(new Spike(x + i * 24, y, 1));
  }
}

// Fungsi untuk menambahkan satu koin ke dalam game
void tambahKoin(float x, float y) {
  coins.add(new Coin(x, y));
}

// Fungsi untuk menambahkan deretan koin dengan jarak tertentu
void barisKoin(float x, float y, int jumlah, float jarak) {
  for (int i = 0; i < jumlah; i++) {
    tambahKoin(x + i * jarak, y);
  }
}

// Class dasar untuk objek platform pijakan dalam ruang 3D
class Platform {
  float x, y, w, h;
  float dx = 0;
  float traksi;

  // Konstruktor untuk mengatur posisi, ukuran, dan traksi platform
  Platform(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    traksi = lv.traksi;
  }

  // Fungsi update dibiarkan kosong agar bisa dioverride oleh platform yang bisa bergerak
  void update() {
  }

  // Menampilkan bentuk 3D platform beserta lapisan atasnya menggunakan fungsi box()
  void display() {
    noStroke();

    // Gambar balok bagian bawah/tanah platform
    pushMatrix();
    translate(x + w / 2, y + h / 2, 0);
    fill(lv.cTanah);
    box(w, h, 56);
    popMatrix();

    // Gambar lapisan atas platform (rumput/salju)
    pushMatrix();
    translate(x + w / 2, y + 5, 0);
    fill(lv.cAtas);
    box(w + 2, 10, 60);
    popMatrix();

    // Tambahkan efek garis batas/pencahayaan tipis di tepi atas
    pushMatrix();
    translate(x + w / 2, y + 1.5, 31);
    fill(lerpColor(lv.cAtas, color(255), 0.45));
    box(w, 3, 2);
    popMatrix();
  }
}

// Class platform yang bisa bergerak bolak-balik (turunan dari class Platform)
class MovingPlatform extends Platform {
  float x0, jarak, kecepatan;
  float fase = 0;

  // Konstruktor memanggil class induk dan menyimpan data batas pergerakan
  MovingPlatform(float x, float y, float w, float h, float jarak, float kecepatan) {
    super(x, y, w, h);
    this.x0 = x;
    this.jarak = jarak;
    this.kecepatan = kecepatan;
  }

  // Update posisi koordinat X menggunakan fungsi gelombang sin agar pergerakannya mulus
  void update() {
    fase += 0.04 * kecepatan;
    float xBaru = x0 + (sin(fase) * 0.5 + 0.5) * jarak;
    
    // Simpan selisih pergerakan agar pemain ikut terbawa saat berdiri di atasnya
    dx = xBaru - x;
    x = xBaru;
  }

  // Menampilkan platform beserta indikator garis kuning di bagian bawahnya
  void display() {
    super.display();

    pushMatrix();
    translate(x + w / 2, y + h + 2, 0);
    fill(255, 215, 60);
    box(w * 0.6, 4, 30);
    popMatrix();
  }
}

// Class untuk objek duri lantai atau stalaktit
class Spike {
  float x, y;
  int arah;

  Spike(float x, float y, int arah) {
    this.x = x;
    this.y = y;
    this.arah = arah;
  }

  // Menentukan warna duri menyesuaikan dengan tema level yang aktif
  color warna() {
    switch (lv.id) {
    case 1:
      return color(225, 65, 50);
    case 2:
      return color(125, 160, 205);
    case 3:
      return color(150, 225, 255);
    case 5:
      return color(255, 120, 40);
    default:
      return color(150, 125, 185);
    }
  }

  // Menggambar bentuk piramida 3D menggunakan susunan segitiga (TRIANGLES)
  void display() {
    noStroke();
    color c = warna();
    float ay = y + 27 * arah;
    float xm = x + 12;

    beginShape(TRIANGLES);
    // Sisi depan
    fill(c);
    vertex(x, y, 14);
    vertex(x + 24, y, 14);
    vertex(xm, ay, 0);

    // Sisi kanan dengan efek shading lebih gelap
    fill(lerpColor(c, color(0), 0.35));
    vertex(x + 24, y, 14);
    vertex(x + 24, y, -14);
    vertex(xm, ay, 0);

    // Sisi belakang
    fill(lerpColor(c, color(0), 0.5));
    vertex(x + 24, y, -14);
    vertex(x, y, -14);
    vertex(xm, ay, 0);

    // Sisi kiri
    fill(lerpColor(c, color(0), 0.2));
    vertex(x, y, -14);
    vertex(x, y, 14);
    vertex(xm, ay, 0);
    endShape();
  }
}

// Class untuk item koin yang bisa dikumpulkan pemain
class Coin {
  float x, y;
  float r = 11; // jari-jari hitbox koin (sama dengan ukuran gambar koin)
  boolean terambil = false;

  Coin(float x, float y) {
    this.x = x;
    this.y = y;
  }

  // Menampilkan koin dengan efek animasi berputar menggunakan skala yang diubah-ubah
  void display() {
    if (terambil) return;

    // Bikin ukuran koin seolah berdenyut
    float ukuran = 18 + sin(waktuAnimasi * 3 + x) * 2;

    pushMatrix();
    translate(x, y);
    noStroke();
    fill(255, 225, 80, 70);
    ellipse(0, 0, ukuran * 2.2, ukuran * 2.2);

    // Animasi putaran semu koin menggunakan fungsi cos pada parameter scale
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

// Class untuk pemain utama (karakter bola)
class Player {
  float x, y;
  float vx = 0;
  float vy = 0;
  float r = 18;           // jari-jari hitbox badan (lingkaran, sama dengan ukuran gambar bola)
  float rBahaya = 13;     // hitbox bahaya (duri) sedikit lebih kecil dari badan agar adil
  float kecepatan = 4.5;
  float gravitasi = 0.48;
  float kekuatanLompat = -10.5;
  float putar = 0;
  int koyote = 0;         // sisa frame toleransi lompat setelah meninggalkan tepi platform

  boolean diTanah = false;
  Platform berdiri = null;

  Player(float xAwal, float yAwal) {
    x = xAwal;
    y = yAwal;
  }

  // Update logika pergerakan fisika, gravitasi, dan tabrakan setiap frame
  void update() {
    // Menghitung target kecepatan horizontal berdasarkan input pemain
    float target = 0;
    if (tombolKiri && !tombolKanan) target = -kecepatan;
    else if (tombolKanan && !tombolKiri) target = kecepatan;

    // Menentukan seberapa licin pijakan saat ini
    float g;
    if (diTanah && berdiri != null) g = berdiri.traksi;
    else g = constrain(lv.traksi * 1.6, 0.18, 1);

    // Hitung pergerakan menggunakan sistem traksi/gesekan
    vx += (target - vx) * g;
    if (abs(vx) < 0.05) vx = 0;

    // Lompat diizinkan saat menapak atau beberapa frame setelah lepas dari tepi (koyote)
    if (permintaanLompat) {
      if (diTanah || koyote > 0) lompat();
      permintaanLompat = false;
    }

    // Tambahkan pengaruh gravitasi konstan agar bola bisa jatuh
    vy += gravitasi;
    vy = min(vy, 12);

    // Reset status pijakan sebelum mengecek tabrakan
    diTanah = false;
    berdiri = null;

    // Gerak dibagi 2 sub-langkah supaya bola tidak menembus platform tipis saat jatuh cepat
    for (int langkah = 0; langkah < 2; langkah++) {
      x += vx / 2;
      y += vy / 2;
      selesaikanTabrakan();
    }

    if (diTanah) koyote = 6;
    else if (koyote > 0) koyote--;

    // Geser posisi pemain jika platform yang dipijaknya sedang bergerak
    if (berdiri != null) x += berdiri.dx;

    // Tahan posisi bola agar tidak keluar dari batas samping arena
    x = constrain(x, r, lv.lebar - r);
    putar += vx / r;
  }

  // Tabrakan lingkaran vs balok: titik terdekat pada platform dicari, lalu bola didorong keluar.
  // Dengan cara ini permukaan atas, sisi samping, sudut, dan bagian bawah platform semuanya solid
  // dan bola tidak bisa lagi "melayang" di tepi atau menembus dinding platform.
  void selesaikanTabrakan() {
    for (Platform p : platforms) {
      float tx = constrain(x, p.x, p.x + p.w);
      float ty = constrain(y, p.y, p.y + p.h);
      float dx = x - tx;
      float dy = y - ty;
      float d2 = dx * dx + dy * dy;
      if (d2 >= r * r) continue;

      if (d2 < 0.0001) {
        // Pusat bola masuk ke dalam balok (misal terjepit platform bergerak): dorong ke atas permukaan.
        y = p.y - r;
        if (vy > 0) vy = 0;
        diTanah = true;
        berdiri = p;
      } else {
        float d = sqrt(d2);
        float nx = dx / d;
        float ny = dy / d;
        x += nx * (r - d);
        y += ny * (r - d);
        if (ny < -0.5) {
          // Mendarat di permukaan atas.
          if (vy > 0) vy = 0;
          diTanah = true;
          berdiri = p;
        } else if (ny > 0.5) {
          // Kepala menabrak bagian bawah platform.
          if (vy < 0) vy = 0;
        } else {
          // Menabrak dinding samping: hentikan dorongan ke arah dinding.
          if (nx > 0 && vx < 0) vx = 0;
          else if (nx < 0 && vx > 0) vx = 0;
        }
      }
    }
  }

  // Fungsi untuk menjalankan lompatan dan memunculkan efek partikel
  void lompat() {
    if (gameState == PLAY) {
      vy = kekuatanLompat;
      diTanah = false;
      koyote = 0;
      if (!modePractice) {
        statLompat++;
        dataKotor = true;
      }
      mainkanSfx(sfxLompat);

      // Munculkan partikel debu lompatan
      for (int i = 0; i < 5; i++) {
        particles.add(new Particle(x, y + r, cyan));
      }
    }
  }

  // Menampilkan grafik bola karakter sesuai skin yang dipakai
  void display() {
    pushMatrix();
    translate(x, y);

    // Animasi deformasi (squash and stretch) menyesuaikan kecepatan jatuh bola
    float s = 1 + constrain(vy * 0.012, -0.12, 0.12);
    scale(1 / s, s);

    noStroke();
    if (lv.gelap) {
      fill(255, 200, 120, 40);
      ellipse(0, 0, r * 5, r * 5);
      fill(255, 200, 120, 60);
      ellipse(0, 0, r * 3.2, r * 3.2);
    }

    bolaSkin(skinAktif, r, putar);

    popMatrix();
  }
}

// Class untuk mengatur efek partikel (seperti bekas lompatan atau efek koin)
class Particle {
  float x, y;
  float vx, vy;
  float umur = 30;
  color warna;

  Particle(float x, float y, color warna) {
    this.x = x;
    this.y = y;
    this.warna = warna;
    vx = random(-2.5, 2.5);
    vy = random(-3.5, 0.5);
  }

  // Update posisi partikel dan kurangi masa umurnya setiap frame
  void update() {
    x += vx;
    y += vy;
    vy += 0.12;
    umur--;
  }

  // Gambar partikel yang semakin memudar transparan saat umurnya hampir habis
  void display() {
    noStroke();
    fill(warna, map(umur, 0, 30, 0, 255));
    ellipse(x, y, map(umur, 0, 30, 1, 7), map(umur, 0, 30, 1, 7));
  }
}

// Fungsi utama untuk update keseluruhan logika permainan (mode continuous)
void updateGame() {
  for (Platform p : platforms) {
    p.update();
  }

  player.update();
  if (!modePractice) cekPrestasi();

  periksaKoin();
  periksaDuri();
  if (gameState != PLAY) return;
  
  periksaCheckpoint();
  periksaKemenangan();
  if (gameState != PLAY) return;

  // Cek apakah pemain jatuh ke jurang (keluar batas bawah layar)
  // Khusus level 5, batas toleransi jatuhnya diturunkan karena ada lava
  float batasBawah = (lv.id == 5) ? 580 : VH + 100;
  if (player.y > batasBawah) {
    kehilanganNyawa();
  }

  // Kamera mengikuti pergerakan pemain secara halus menggunakan fungsi lerp
  float targetCam = player.x - VW * 0.38;
  cameraX = constrain(lerp(cameraX, targetCam, 0.2), 0, lv.lebar - VW);

  // Update data partikel, dan hapus partikel dari array jika sudah hilang (umurnya habis)
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (p.umur <= 0) {
      particles.remove(i);
    }
  }

  // Memicu efek kilatan petir acak khusus di level 1 (hujan)
  if (lv.id == 1 && random(1) < 0.0025) {
    kilat = 1;
  }
  
  // Mengurangi intensitas kilat secara perlahan
  kilat *= 0.92;
}

// Cek apakah pemain menyentuh area koin yang belum diambil
void periksaKoin() {
  if (modePractice) return; // practice mode: koin tidak bisa diambil
  for (Coin c : coins) {
    // Kena tepat saat lingkaran bola (r + 2 outline) dan lingkaran koin saling bersentuhan.
    if (!c.terambil && dist(player.x, player.y, c.x, c.y) < player.r + 2 + c.r) {
      c.terambil = true;
      skor += 100;
      jumlahKoin++;
      dompet++;
      statKoinTotal++;
      dataKotor = true;
      mainkanSfx(sfxKoin);
      
      for (int i = 0; i < 8; i++) {
        particles.add(new Particle(c.x, c.y, color(255, 205, 65)));
      }
    }
  }
}

// Cek tabrakan antara bola pemain dengan semua rintangan duri
void periksaDuri() {
  for (Spike s : spikes) {
    if (bolaMenyentuhSegitiga(
      player.x, player.y, player.rBahaya,
      s.x, s.y,
      s.x + 12, s.y + 27 * s.arah,
      s.x + 24, s.y)) {
      kehilanganNyawa();
      return;
    }
  }
}

// Fungsi matematika untuk mengecek tabrakan antara objek lingkaran dan segitiga
boolean bolaMenyentuhSegitiga(float cx, float cy, float r,
  float x1, float y1, float x2, float y2, float x3, float y3) {
  if (titikDalamSegitiga(cx, cy, x1, y1, x2, y2, x3, y3)) return true;
  if (jarakTitikKeGaris(cx, cy, x1, y1, x2, y2) <= r ||
      jarakTitikKeGaris(cx, cy, x2, y2, x3, y3) <= r ||
      jarakTitikKeGaris(cx, cy, x3, y3, x1, y1) <= r) return true;
  return false;
}

// Mengecek apakah titik pusat bola ada tepat di dalam area segitiga duri
boolean titikDalamSegitiga(float px, float py, float x1, float y1,
  float x2, float y2, float x3, float y3) {
  float d1 = (px - x2) * (y1 - y2) - (x1 - x2) * (py - y2);
  float d2 = (px - x3) * (y2 - y3) - (x2 - x3) * (py - y3);
  float d3 = (px - x1) * (y3 - y1) - (x3 - x1) * (py - y1);
  boolean negatif = d1 < 0 || d2 < 0 || d3 < 0;
  boolean positif = d1 > 0 || d2 > 0 || d3 > 0;
  return !(negatif && positif);
}

// Menghitung jarak terpendek dari sebuah titik menuju ke satu garis (sisi segitiga)
float jarakTitikKeGaris(float px, float py, float x1, float y1, float x2, float y2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  
  float pk = dx * dx + dy * dy;
  if (pk == 0) return dist(px, py, x1, y1);
  float t = constrain(((px - x1) * dx + (py - y1) * dy) / pk, 0, 1);
  return dist(px, py, x1 + t * dx, y1 + t * dy);
}

// Fungsi untuk mengaktifkan tiang checkpoint saat pemain melewatinya
void periksaCheckpoint() {
  if (player.x > lv.cpX && !checkpointAktif) {
    checkpointAktif = true;
    checkpointX = lv.cpX;
    if (!modePractice) {
      skor += 250;
      statCheckpoint++;
      dataKotor = true;
    }
    mainkanSfx(sfxCheckpoint);
    
    for (int i = 0; i < 18; i++) {
      particles.add(new Particle(lv.cpX, lv.cpY - 60, color(255, 220, 40)));
    }
  }
}

// Cek apakah posisi pemain sudah mencapai area portal hijau di ujung kanan level
void periksaKemenangan() {
  if (player.x >= lv.lebar - 120) {
    if (!modePractice) skor += 500;
    mainkanSfx(sfxMenang);
    if (!modePractice) prestasiLevelSelesai(level);
    if (level < JUMLAH_LEVEL) { // Cek apakah level ini adalah level terakhir atau bukan
      ubahState(LEVEL_DONE);
    } else {
      ubahState(WIN);
    }
    simpanData();
  }
}

// Fungsi untuk menangani penalti ketika pemain mati (jatuh atau kena duri)
void kehilanganNyawa() {
  if (!modePractice) { // practice mode: nyawa tak terbatas
    nyawa--;
    statMati++;
    matiDiLevel++;
    dataKotor = true;
  }
  mainkanSfx(sfxKena);
  
  for (int i = 0; i < 14; i++) {
    particles.add(new Particle(player.x, player.y, skinTengah[skinAktif]));
  }
  resetInput();

  // Jika nyawa habis tampilkan layar Game Over, jika tidak respawn di checkpoint terakhir
  if (!modePractice && nyawa <= 0) {
    simpanData();
    ubahState(LOSE);
  } else if (modePractice && practiceCpAda) {
    player = new Player(practiceCpX, practiceCpY);
    cameraX = max(0, practiceCpX - 300);
  } else {
    player = new Player(checkpointX + 30, lv.cpY - 90);
    cameraX = max(0, checkpointX - 300);
  }
}

// Mendeteksi event klik pada mouse dan menjalankan aksi tombol GUI sesuai layarnya
void mousePressed() {
  switch (gameState) {
  case MENU:
    if (btnMulai.hover()) {
      klik();
      modePractice = false;
      mulaiGameBaru(1);
    } else if (btnPilih.hover()) {
      klik();
      modePractice = false;
      ubahState(PILIH);
    } else if (btnPractice.hover()) {
      klik();
      modePractice = true;
      ubahState(PILIH);
    } else if (btnToko.hover()) {
      klik();
      ubahState(SKIN);
    } else if (btnPrestasi.hover()) {
      klik();
      ubahState(PRESTASI);
    } else if (btnPetunjuk.hover()) {
      klik();
      ubahState(HELP);
    } else {
      sliderMenu.tekan();
    }
    break;

  case PILIH:
    for (int i = 1; i <= 5; i++) { // Sesuaikan batas for loop dengan jumlah ketersediaan level
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

  case SKIN:
    for (int i = 0; i < JUMLAH_SKIN; i++) {
      if (tombolSkinHover(i)) {
        aksiSkin(i);
        return;
      }
    }
    if (btnKembali.hover()) {
      klik();
      ubahState(MENU);
    }
    break;

  case PRESTASI:
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

// Mengatur perubahan nilai volume ketika slider ditarik/digeser oleh kursor
void mouseDragged() {
  if (sliderMenu.drag || sliderPause.drag) {
    if (gameState == MENU) sliderMenu.ubah();
    if (gameState == PAUSE) sliderPause.ubah();
  }
}

// Mereset status interaksi drag saat mouse dilepas
void mouseReleased() {
  sliderMenu.drag = false;
  sliderPause.drag = false;
}

// Mengatur fungsi navigasi tombol aksi pada layar post-game (menang, lanjut, ngulang)
void aksiUtama() {
  if (gameState == LEVEL_DONE) mulaiLevelBaru(level + 1);
  else if (gameState == WIN) mulaiGameBaru(1);
  else if (gameState == LOSE) ulangLevel();
}

// Membaca input spesifik dari keyboard pengguna
void keyPressed() {
  // F11: tukar jendela maximized (ada tombol minimize) dengan layar penuh murni.
  if (keyCode == 122) {
    ubahLayarPenuh();
    return;
  }

  if (key == ESC) {
    key = 0;
    if (gameState == PLAY) ubahState(PAUSE);
    else if (gameState == PAUSE) ubahState(PLAY);
    else if (gameState == RULES) tutupAturan();
    else if (gameState == SKIN || gameState == PRESTASI || gameState == PILIH || gameState == HELP) ubahState(MENU);
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

  // B: tampilkan / sembunyikan hitbox.
  if (key == 'b' || key == 'B') tampilHitbox = !tampilHitbox;

  // Practice mode: C = pasang checkpoint di posisi sekarang (harus menapak), X = hapus checkpoint buatan.
  if (modePractice) {
    if ((key == 'c' || key == 'C') && player.diTanah) {
      practiceCpAda = true;
      practiceCpX = player.x;
      practiceCpY = player.y;
      mainkanSfx(sfxCheckpoint);
    }
    if (key == 'x' || key == 'X') practiceCpAda = false;
  }
}

// Membatalkan status pergerakan input saat tombol arah dilepas
void keyReleased() {
  if (key == 'a' || key == 'A' || keyCode == LEFT) tombolKiri = false;
  if (key == 'd' || key == 'D' || keyCode == RIGHT) tombolKanan = false;
  if (key == ' ' || key == 'w' || key == 'W' || keyCode == UP) tombolLompat = false;
}

// Memastikan pemain tidak langsung melompat atau bergerak saat masuk ke level baru
void resetInput() {
  tombolKiri = false;
  tombolKanan = false;
  tombolLompat = false;
  permintaanLompat = false;
}
