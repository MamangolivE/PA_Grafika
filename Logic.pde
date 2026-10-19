// =====================================================
<<<<<<< HEAD
// LOGIKA UTAMA GAME
// Berisi pengaturan alur state, class objek (Level, Platform, Spike, Coin, Player, Particle),
// serta fungsi fisika, deteksi tabrakan (collision), dan kontrol input.
// =====================================================

// Fungsi untuk mengganti state game dan reset input tombol agar tidak tersangkut
=======
// LOGIKA GAME
//   Berisi: alur level/state, class objek (Level, Platform, Spike, Coin, Player, Particle),
//   fisika & tabrakan, checkpoint/nyawa/kemenangan, dan input mouse/keyboard.
// =====================================================

// Fungsi ubahState: Mengganti state game, mereset animasi popup dan input.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void ubahState(int s) {
  gameState = s;
  popupAnim = 0;
  resetInput();
}

<<<<<<< HEAD
// Fungsi untuk memulai game baru dari awal
=======
// Fungsi mulaiGameBaru: Memulai permainan baru dari level l dengan nyawa, skor, dan koin direset.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void mulaiGameBaru(int l) {
  nyawa = 3;
  skor = 0;
  jumlahKoin = 0;
  mulaiLevelBaru(l);
}

<<<<<<< HEAD
// Persiapan sebelum memuat level, termasuk mengatur layar loading
=======
// Fungsi mulaiLevelBaru: Menyiapkan level l: ambil data level, reset penghitung loading, lalu masuk state LOADING.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
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

<<<<<<< HEAD
// Mengembalikan skor dan koin ke kondisi awal level jika pemain mati (game over)
=======
// Fungsi ulangLevel: Mengulang level saat game over (skor dikembalikan ke awal level).
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void ulangLevel() {
  skor = skorAwalLevel;
  jumlahKoin = koinAwalLevel;
  nyawa = 3;
  mulaiLevelBaru(level);
}

<<<<<<< HEAD
// Fungsi untuk kembali ke menu utama dan memutar musik menu
=======
// Fungsi keMenu: Kembali ke menu utama dan memutar musik menu.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void keMenu() {
  mainkanBgm(0);
  ubahState(MENU);
}

<<<<<<< HEAD
// Membuka popup aturan level dan menyimpan state sebelumnya agar bisa kembali
=======
// Fungsi bukaAturan: Membuka popup aturan, mengingat state asal agar bisa kembali.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void bukaAturan(int kembaliKe) {
  stateSebelumRules = kembaliKe;
  ubahState(RULES);
}

<<<<<<< HEAD
// Menutup popup aturan dan kembali ke state game terakhir
=======
// Fungsi tutupAturan: Menutup popup aturan dan kembali ke state sebelumnya.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void tutupAturan() {
  ubahState(stateSebelumRules);
}

<<<<<<< HEAD
// Fungsi untuk membersihkan semua objek lama dan membangun ulang arena level yang baru
=======
// Fungsi buatLevel: Mengosongkan semua daftar objek lalu membangun level aktif, membuat cuaca dan pemain.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void buatLevel() {
  platforms.clear();
  spikes.clear();
  coins.clear();
  particles.clear();

  cameraX = 0;
  checkpointX = 80;
  checkpointAktif = false;

<<<<<<< HEAD
  // Load layout objek sesuai dengan nomor level yang aktif
=======
  // switch: bangun level sesuai nomor level.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
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
<<<<<<< HEAD
  case 4:
    bangunLevel4();
    break;
  default:
    bangunLevel5(); 
    break;
  }

  // Buat objek cuaca dan tempatkan pemain di titik awal
=======
  default:
    bangunLevel4();
    break;
  }

>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  cuaca = new EfekCuaca(lv.tipeCuaca);
  player = new Player(100, 490);
}

<<<<<<< HEAD
// Konstanta untuk tipe cuaca
final int C_NONE = 0, C_HUJAN = 1, C_SALJU = 2, C_ES = 3, C_GOA = 4;

// Class untuk menyimpan data konfigurasi dan settingan dari tiap level
=======
// Konstanta jenis cuaca.
final int C_NONE = 0, C_HUJAN = 1, C_SALJU = 2, C_ES = 3, C_GOA = 4;

// ----- CLASS Level: wadah data satu level (nama, aturan, ukuran dunia, licin, cuaca, warna). -----
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
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

<<<<<<< HEAD
// Fungsi untuk mengambil data level berdasarkan nomor levelnya
Level infoLevel(int id) {
=======
// Fungsi infoLevel: Mengembalikan data Level sesuai nomor level.
Level infoLevel(int id) {
  // switch: pilih data level.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  switch (id) {
  case 1:
    return infoLevel1();
  case 2:
    return infoLevel2();
  case 3:
    return infoLevel3();
<<<<<<< HEAD
  case 4:
    return infoLevel4();
  default:
    return infoLevel5(); 
  }
}

// Fungsi untuk menambahkan duri secara berjejer di lantai
void tambahDuri(float x, float y, int jumlah) {
=======
  default:
    return infoLevel4();
  }
}

// Fungsi tambahDuri: Menambah deretan duri lantai ke daftar spikes.
void tambahDuri(float x, float y, int jumlah) {
  // Perulangan for: tambah duri berjajar ke kanan.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  for (int i = 0; i < jumlah; i++) {
    spikes.add(new Spike(x + i * 24, y, -1));
  }
}

<<<<<<< HEAD
// Fungsi untuk menambahkan duri menggantung (stalaktit) secara berjejer
void tambahStalaktit(float x, float y, int jumlah) {
=======
// Fungsi tambahStalaktit: Menambah deretan stalaktit menggantung ke daftar spikes.
void tambahStalaktit(float x, float y, int jumlah) {
  // Perulangan for: tambah stalaktit berjajar ke kanan.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  for (int i = 0; i < jumlah; i++) {
    spikes.add(new Spike(x + i * 24, y, 1));
  }
}

<<<<<<< HEAD
// Fungsi untuk menambahkan satu koin ke dalam game
=======
// Fungsi tambahKoin: Menambah satu koin ke daftar coins.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void tambahKoin(float x, float y) {
  coins.add(new Coin(x, y));
}

<<<<<<< HEAD
// Fungsi untuk menambahkan deretan koin dengan jarak tertentu
void barisKoin(float x, float y, int jumlah, float jarak) {
=======
// Fungsi barisKoin: Menambah sebaris koin dengan jarak tetap.
void barisKoin(float x, float y, int jumlah, float jarak) {
  // Perulangan for: tambah koin berjajar dengan jarak tetap.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  for (int i = 0; i < jumlah; i++) {
    tambahKoin(x + i * jarak, y);
  }
}

<<<<<<< HEAD
// Class dasar untuk objek platform pijakan dalam ruang 3D
=======
// ----- CLASS Platform: pijakan 3D (box) dengan posisi, ukuran, dan tingkat licin. -----
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
class Platform {
  float x, y, w, h;
  float dx = 0;
  float traksi;

<<<<<<< HEAD
  // Konstruktor untuk mengatur posisi, ukuran, dan traksi platform
=======
  // Konstruktor Platform: simpan posisi/ukuran dan ambil traksi dari level.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  Platform(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    traksi = lv.traksi;
  }

<<<<<<< HEAD
  // Fungsi update dibiarkan kosong agar bisa dioverride oleh platform yang bisa bergerak
  void update() {
  }

  // Menampilkan bentuk 3D platform beserta lapisan atasnya menggunakan fungsi box()
  void display() {
    noStroke();

    // Gambar balok bagian bawah/tanah platform
=======
  // Kosong pada platform biasa; di-override oleh MovingPlatform (polymorphism).
  void update() {
  }

  // Menggambar platform: badan tanah, lapisan atas, dan kilau tipis memakai box.
  void display() {
    noStroke();

>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    pushMatrix();
    translate(x + w / 2, y + h / 2, 0);
    fill(lv.cTanah);
    box(w, h, 56);
    popMatrix();

<<<<<<< HEAD
    // Gambar lapisan atas platform (rumput/salju)
=======
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    pushMatrix();
    translate(x + w / 2, y + 5, 0);
    fill(lv.cAtas);
    box(w + 2, 10, 60);
    popMatrix();

<<<<<<< HEAD
    // Tambahkan efek garis batas/pencahayaan tipis di tepi atas
=======
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    pushMatrix();
    translate(x + w / 2, y + 1.5, 31);
    fill(lerpColor(lv.cAtas, color(255), 0.45));
    box(w, 3, 2);
    popMatrix();
  }
}

<<<<<<< HEAD
// Class platform yang bisa bergerak bolak-balik (turunan dari class Platform)
=======
// ----- CLASS MovingPlatform (turunan Platform): platform yang bergerak kiri-kanan memakai sin (inheritance). -----
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
class MovingPlatform extends Platform {
  float x0, jarak, kecepatan;
  float fase = 0;

<<<<<<< HEAD
  // Konstruktor memanggil class induk dan menyimpan data batas pergerakan
=======
  // Konstruktor: panggil super lalu simpan jarak dan kecepatan gerak.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  MovingPlatform(float x, float y, float w, float h, float jarak, float kecepatan) {
    super(x, y, w, h);
    this.x0 = x;
    this.jarak = jarak;
    this.kecepatan = kecepatan;
  }

<<<<<<< HEAD
  // Update posisi koordinat X menggunakan fungsi gelombang sin agar pergerakannya mulus
  void update() {
    fase += 0.04 * kecepatan;
    float xBaru = x0 + (sin(fase) * 0.5 + 0.5) * jarak;
    
    // Simpan selisih pergerakan agar pemain ikut terbawa saat berdiri di atasnya
=======
  // Menghitung posisi baru dengan sin dan menyimpan selisihnya (dx) agar pemain ikut terbawa.
  void update() {
    fase += 0.04 * kecepatan;
    // Posisi baru platform bergerak berdasarkan gelombang sin.
    float xBaru = x0 + (sin(fase) * 0.5 + 0.5) * jarak;
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    dx = xBaru - x;
    x = xBaru;
  }

<<<<<<< HEAD
  // Menampilkan platform beserta indikator garis kuning di bagian bawahnya
=======
  // Menggambar platform biasa ditambah garis kuning penanda platform bergerak.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  void display() {
    super.display();

    pushMatrix();
    translate(x + w / 2, y + h + 2, 0);
    fill(255, 215, 60);
    box(w * 0.6, 4, 30);
    popMatrix();
  }
}

<<<<<<< HEAD
// Class untuk objek duri lantai atau stalaktit
=======
// ----- CLASS Spike: duri lantai atau stalaktit berbentuk piramida; arah -1 = ke atas, 1 = menggantung. -----
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
class Spike {
  float x, y;
  int arah;

<<<<<<< HEAD
=======
  // Konstruktor Spike: posisi dan arah.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  Spike(float x, float y, int arah) {
    this.x = x;
    this.y = y;
    this.arah = arah;
  }

<<<<<<< HEAD
  // Menentukan warna duri menyesuaikan dengan tema level yang aktif
  color warna() {
=======
  // Warna duri sesuai level (switch).
  color warna() {
    // switch: warna duri tiap level.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
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

<<<<<<< HEAD
  // Menggambar bentuk piramida 3D menggunakan susunan segitiga (TRIANGLES)
=======
  // Menggambar piramida dari 4 segitiga dengan warna sisi berbeda agar terlihat 3D.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  void display() {
    noStroke();
    color c = warna();
    float ay = y + 27 * arah;
    float xm = x + 12;

    beginShape(TRIANGLES);
<<<<<<< HEAD
    // Sisi depan
=======
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    fill(c);
    vertex(x, y, 14);
    vertex(x + 24, y, 14);
    vertex(xm, ay, 0);

<<<<<<< HEAD
    // Sisi kanan dengan efek shading lebih gelap
=======
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    fill(lerpColor(c, color(0), 0.35));
    vertex(x + 24, y, 14);
    vertex(x + 24, y, -14);
    vertex(xm, ay, 0);

<<<<<<< HEAD
    // Sisi belakang
=======
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    fill(lerpColor(c, color(0), 0.5));
    vertex(x + 24, y, -14);
    vertex(x, y, -14);
    vertex(xm, ay, 0);

<<<<<<< HEAD
    // Sisi kiri
=======
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    fill(lerpColor(c, color(0), 0.2));
    vertex(x, y, -14);
    vertex(x, y, 14);
    vertex(xm, ay, 0);
    endShape();
  }
}

<<<<<<< HEAD
// Class untuk item koin yang bisa dikumpulkan pemain
=======
// ----- CLASS Coin: koin yang bisa diambil; tampil berdenyut dan berputar. -----
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
class Coin {
  float x, y;
  boolean terambil = false;

<<<<<<< HEAD
=======
  // Konstruktor Coin: posisi koin.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  Coin(float x, float y) {
    this.x = x;
    this.y = y;
  }

<<<<<<< HEAD
  // Menampilkan koin dengan efek animasi berputar menggunakan skala yang diubah-ubah
  void display() {
    if (terambil) return;

    // Bikin ukuran koin seolah berdenyut
=======
  // Menggambar koin dari ellipse; scale horizontal berubah-ubah agar tampak berputar.
  void display() {
    if (terambil) return;

    // Ukuran koin berdenyut dengan sin.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    float ukuran = 18 + sin(waktuAnimasi * 3 + x) * 2;

    pushMatrix();
    translate(x, y);
    noStroke();
    fill(255, 225, 80, 70);
    ellipse(0, 0, ukuran * 2.2, ukuran * 2.2);

<<<<<<< HEAD
    // Animasi putaran semu koin menggunakan fungsi cos pada parameter scale
=======
    // Lebar koin mengecil-membesar sehingga terlihat berputar.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
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

<<<<<<< HEAD
// Class untuk pemain utama (karakter bola)
=======
// ----- CLASS Player: bola pemain (fisika gerak, gravitasi, lompat, tabrakan platform). -----
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
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

<<<<<<< HEAD
=======
  // Konstruktor Player: posisi awal.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  Player(float xAwal, float yAwal) {
    x = xAwal;
    y = yAwal;
  }

<<<<<<< HEAD
  // Update logika pergerakan fisika, gravitasi, dan tabrakan setiap frame
  void update() {
    // Menghitung target kecepatan horizontal berdasarkan input pemain
=======
  // Fisika pemain per frame: gerak horizontal dengan traksi, lompat, gravitasi, dan tabrakan dengan platform.
  void update() {
    // Kecepatan tujuan dari tombol kiri/kanan.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    float target = 0;
    if (tombolKiri && !tombolKanan) target = -kecepatan;
    else if (tombolKanan && !tombolKiri) target = kecepatan;

<<<<<<< HEAD
    // Menentukan seberapa licin pijakan saat ini
=======
    // Pilih tingkat traksi: dari platform jika menapak, dari level jika di udara.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    float g;
    if (diTanah && berdiri != null) g = berdiri.traksi;
    else g = constrain(lv.traksi * 1.6, 0.18, 1);

<<<<<<< HEAD
    // Hitung pergerakan menggunakan sistem traksi/gesekan
    vx += (target - vx) * g;
    if (abs(vx) < 0.05) vx = 0;

    // Pemain hanya bisa melompat jika posisinya menapak di permukaan
=======
    // Traksi: makin kecil g makin licin (kecepatan menuju target pelan-pelan).
    vx += (target - vx) * g;
    if (abs(vx) < 0.05) vx = 0;

    // Lompat hanya jika ada permintaan dan bola menapak.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    if (permintaanLompat) {
      if (diTanah) lompat();
      permintaanLompat = false;
    }

    x += vx;
<<<<<<< HEAD
    float yLama = y;

    // Tambahkan pengaruh gravitasi konstan agar bola bisa jatuh
=======

    float yLama = y;
    // Gravitasi menambah kecepatan jatuh tiap frame.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    vy += gravitasi;
    vy = min(vy, 12);
    y += vy;

<<<<<<< HEAD
    // Reset status pijakan sebelum mengecek tabrakan
    diTanah = false;
    berdiri = null;

    // Cek deteksi tabrakan (collision) antara bola dengan permukaan platform
    for (Platform p : platforms) {
      boolean masuk = x + r > p.x && x - r < p.x + p.w;
      
      // Jika bola jatuh dari atas dan melewati batas permukaan platform
=======
    // Reset status menapak; dihitung ulang lewat tabrakan di bawah.
    diTanah = false;
    berdiri = null;

    // Perulangan for-each: cek tabrakan bola dengan setiap platform.
    for (Platform p : platforms) {
      boolean masuk = x + r > p.x && x - r < p.x + p.w;
      // Pendaratan: bola dari atas menyentuh permukaan platform.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
      if (masuk && yLama + r <= p.y + 1 && y + r >= p.y && vy >= 0) {
        y = p.y - r;
        vy = 0;
        diTanah = true;
        berdiri = p;
      }
    }

<<<<<<< HEAD
    // Geser posisi pemain jika platform yang dipijaknya sedang bergerak
    if (berdiri != null) x += berdiri.dx;
    
    // Tahan posisi bola agar tidak keluar dari batas samping arena
=======
    // Ikut terbawa platform yang sedang bergerak.
    if (berdiri != null) x += berdiri.dx;
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    x = constrain(x, r, lv.lebar - r);
    putar += vx / r;
  }

<<<<<<< HEAD
  // Fungsi untuk menjalankan lompatan dan memunculkan efek partikel
=======
  // Membuat bola melompat dan mengeluarkan partikel serta suara.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  void lompat() {
    if (diTanah && gameState == PLAY) {
      vy = kekuatanLompat;
      diTanah = false;
      mainkanSfx(sfxLompat);
<<<<<<< HEAD
      
      // Munculkan partikel debu lompatan
=======
      // Perulangan for: keluarkan 5 partikel debu.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
      for (int i = 0; i < 5; i++) {
        particles.add(new Particle(x, y + r, cyan));
      }
    }
  }

<<<<<<< HEAD
  // Menampilkan grafik bola karakter
=======
  // Menggambar bola dari ellipse bertumpuk, dengan squash-stretch dan bintik yang berputar.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  void display() {
    pushMatrix();
    translate(x, y);

<<<<<<< HEAD
    // Animasi deformasi (squash and stretch) menyesuaikan kecepatan jatuh bola
    float s = 1 + constrain(vy * 0.012, -0.12, 0.12);
=======
    float s = 1 + constrain(vy * 0.012, -0.12, 0.12);
    // Squash & stretch: bola memanjang saat jatuh/naik (transformasi scale).
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    scale(1 / s, s);

    noStroke();
    if (lv.gelap) {
      fill(255, 200, 120, 40);
      ellipse(0, 0, r * 5, r * 5);
      fill(255, 200, 120, 60);
      ellipse(0, 0, r * 3.2, r * 3.2);
    }

<<<<<<< HEAD
=======
    // Badan bola: lapisan tepi gelap, warna utama, lalu kilau.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    fill(120, 15, 15);
    ellipse(0, 0, r * 2 + 4, r * 2 + 4);
    fill(195, 35, 35);
    ellipse(0, 0, r * 2, r * 2);
    fill(235, 55, 45);
    ellipse(-2, -2, r * 1.72, r * 1.72);

<<<<<<< HEAD
    // Putar titik corak bola agar terlihat menggelinding natural
=======
    // Putar bintik agar terlihat menggelinding (transformasi rotate).
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    rotate(putar);
    fill(255, 190, 160);
    ellipse(r * 0.5, -r * 0.35, r * 0.4, r * 0.4);
    fill(255, 255, 255, 200);
    ellipse(-r * 0.45, r * 0.4, r * 0.22, r * 0.22);

    popMatrix();
  }
}

<<<<<<< HEAD
// Class untuk mengatur efek partikel (seperti bekas lompatan atau efek koin)
=======
// ----- CLASS Particle: partikel kecil efek koin, lompat, dan terkena duri. -----
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
class Particle {
  float x, y;
  float vx, vy;
  float umur = 30;
  color warna;

<<<<<<< HEAD
=======
  // Konstruktor Particle: posisi, warna, dan kecepatan acak.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  Particle(float x, float y, color warna) {
    this.x = x;
    this.y = y;
    this.warna = warna;
    vx = random(-2.5, 2.5);
    vy = random(-3.5, 0.5);
  }

<<<<<<< HEAD
  // Update posisi partikel dan kurangi masa umurnya setiap frame
=======
  // Gerak partikel dengan gravitasi dan umur berkurang.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  void update() {
    x += vx;
    y += vy;
    vy += 0.12;
    umur--;
  }

<<<<<<< HEAD
  // Gambar partikel yang semakin memudar transparan saat umurnya hampir habis
=======
  // Menggambar partikel yang mengecil dan memudar sesuai umur.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  void display() {
    noStroke();
    fill(warna, map(umur, 0, 30, 0, 255));
    ellipse(x, y, map(umur, 0, 30, 1, 7), map(umur, 0, 30, 1, 7));
  }
}

<<<<<<< HEAD
// Fungsi utama untuk update keseluruhan logika permainan (mode continuous)
void updateGame() {
=======
// Fungsi updateGame: Update satu frame gameplay: platform, pemain, pemeriksaan tabrakan, kamera, partikel, dan petir.
void updateGame() {
  // Perulangan for-each: update semua platform.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  for (Platform p : platforms) {
    p.update();
  }

  player.update();

  periksaKoin();
  periksaDuri();
  if (gameState != PLAY) return;
<<<<<<< HEAD
  
=======
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  periksaCheckpoint();
  periksaKemenangan();
  if (gameState != PLAY) return;

<<<<<<< HEAD
  // Cek apakah pemain jatuh ke jurang (keluar batas bawah layar)
  // Khusus level 5, batas toleransi jatuhnya diturunkan karena ada lava
  float batasBawah = (lv.id == 5) ? 580 : height + 100;
  if (player.y > batasBawah) {
    kehilanganNyawa();
  }

  // Kamera mengikuti pergerakan pemain secara halus menggunakan fungsi lerp
  float targetCam = player.x - width * 0.38;
  cameraX = constrain(lerp(cameraX, targetCam, 0.2), 0, lv.lebar - width);

  // Update data partikel, dan hapus partikel dari array jika sudah hilang (umurnya habis)
=======
  // Jatuh ke jurang = kehilangan nyawa.
  if (player.y > height + 100) {
    kehilanganNyawa();
  }

  float targetCam = player.x - width * 0.38;
  // Kamera mengikuti pemain dengan halus (lerp) dan dibatasi tepi level.
  cameraX = constrain(lerp(cameraX, targetCam, 0.2), 0, lv.lebar - width);

  // Perulangan for (mundur): update partikel dan hapus yang sudah habis umurnya.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (p.umur <= 0) {
      particles.remove(i);
    }
  }

<<<<<<< HEAD
  // Memicu efek kilatan petir acak khusus di level 1 (hujan)
  if (lv.id == 1 && random(1) < 0.0025) {
    kilat = 1;
  }
  
  // Mengurangi intensitas kilat secara perlahan
  kilat *= 0.92;
}

// Cek apakah pemain menyentuh area koin yang belum diambil
void periksaKoin() {
  for (Coin c : coins) {
=======
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
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    if (!c.terambil && dist(player.x, player.y, c.x, c.y) < 30) {
      c.terambil = true;
      skor += 100;
      jumlahKoin++;
      mainkanSfx(sfxKoin);
<<<<<<< HEAD
      
=======
      // Perulangan for: keluarkan 8 partikel.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
      for (int i = 0; i < 8; i++) {
        particles.add(new Particle(c.x, c.y, color(255, 205, 65)));
      }
    }
  }
}

<<<<<<< HEAD
// Cek tabrakan antara bola pemain dengan semua rintangan duri
void periksaDuri() {
=======
// Fungsi periksaDuri: Memeriksa tabrakan bola dengan semua duri.
void periksaDuri() {
  // Perulangan for-each: cek tabrakan dengan setiap duri.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
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

<<<<<<< HEAD
// Fungsi matematika untuk mengecek tabrakan antara objek lingkaran dan segitiga
=======
// Fungsi bolaMenyentuhSegitiga: Tabrakan lingkaran-segitiga: titik di dalam segitiga atau jarak ke sisi kurang dari radius.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
boolean bolaMenyentuhSegitiga(float cx, float cy, float r,
  float x1, float y1, float x2, float y2, float x3, float y3) {
  if (titikDalamSegitiga(cx, cy, x1, y1, x2, y2, x3, y3)) return true;
  if (jarakTitikKeGaris(cx, cy, x1, y1, x2, y2) <= r ||
      jarakTitikKeGaris(cx, cy, x2, y2, x3, y3) <= r ||
      jarakTitikKeGaris(cx, cy, x3, y3, x1, y1) <= r) return true;
  return false;
}

<<<<<<< HEAD
// Mengecek apakah titik pusat bola ada tepat di dalam area segitiga duri
=======
// Fungsi titikDalamSegitiga: Menguji apakah titik berada di dalam segitiga (tanda hasil kali silang).
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
boolean titikDalamSegitiga(float px, float py, float x1, float y1,
  float x2, float y2, float x3, float y3) {
  float d1 = (px - x2) * (y1 - y2) - (x1 - x2) * (py - y2);
  float d2 = (px - x3) * (y2 - y3) - (x2 - x3) * (py - y3);
  float d3 = (px - x1) * (y3 - y1) - (x3 - x1) * (py - y1);
  boolean negatif = d1 < 0 || d2 < 0 || d3 < 0;
  boolean positif = d1 > 0 || d2 > 0 || d3 > 0;
  return !(negatif && positif);
}

<<<<<<< HEAD
// Menghitung jarak terpendek dari sebuah titik menuju ke satu garis (sisi segitiga)
float jarakTitikKeGaris(float px, float py, float x1, float y1, float x2, float y2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  
=======
// Fungsi jarakTitikKeGaris: Jarak terdekat dari titik ke sebuah ruas garis.
float jarakTitikKeGaris(float px, float py, float x1, float y1, float x2, float y2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  // Proyeksi titik ke garis, dibatasi di dalam ruas (constrain).
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  float pk = dx * dx + dy * dy;
  if (pk == 0) return dist(px, py, x1, y1);
  float t = constrain(((px - x1) * dx + (py - y1) * dy) / pk, 0, 1);
  return dist(px, py, x1 + t * dx, y1 + t * dy);
}

<<<<<<< HEAD
// Fungsi untuk mengaktifkan tiang checkpoint saat pemain melewatinya
void periksaCheckpoint() {
=======
// Fungsi periksaCheckpoint: Mengaktifkan checkpoint saat bola melewati bendera (+250 skor).
void periksaCheckpoint() {
  // Checkpoint aktif sekali saat bola melewati bendera.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  if (player.x > lv.cpX && !checkpointAktif) {
    checkpointAktif = true;
    checkpointX = lv.cpX;
    skor += 250;
    mainkanSfx(sfxCheckpoint);
<<<<<<< HEAD
    
=======
    // Perulangan for: keluarkan 18 partikel perayaan.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
    for (int i = 0; i < 18; i++) {
      particles.add(new Particle(lv.cpX, lv.cpY - 60, color(255, 220, 40)));
    }
  }
}

<<<<<<< HEAD
// Cek apakah posisi pemain sudah mencapai area portal hijau di ujung kanan level
void periksaKemenangan() {
  if (player.x >= lv.lebar - 120) {
    skor += 500;
    mainkanSfx(sfxMenang);
    if (level < 5) { // Cek apakah level ini adalah level terakhir atau bukan
=======
// Fungsi periksaKemenangan: Mengecek apakah bola mencapai portal; lanjut ke popup level selesai atau tamat.
void periksaKemenangan() {
  // Menang bila bola sudah dekat portal di ujung level.
  if (player.x >= lv.lebar - 120) {
    skor += 500;
    mainkanSfx(sfxMenang);
    if (level < JUMLAH_LEVEL) {
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
      ubahState(LEVEL_DONE);
    } else {
      ubahState(WIN);
    }
  }
}

<<<<<<< HEAD
// Fungsi untuk menangani penalti ketika pemain mati (jatuh atau kena duri)
void kehilanganNyawa() {
  nyawa--;
  mainkanSfx(sfxKena);
  
=======
// Fungsi kehilanganNyawa: Mengurangi nyawa; respawn di checkpoint atau game over jika nyawa habis.
void kehilanganNyawa() {
  nyawa--;
  mainkanSfx(sfxKena);
  // Perulangan for: keluarkan 14 partikel merah.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  for (int i = 0; i < 14; i++) {
    particles.add(new Particle(player.x, player.y, color(235, 55, 45)));
  }
  resetInput();

<<<<<<< HEAD
  // Jika nyawa habis tampilkan layar Game Over, jika tidak respawn di checkpoint terakhir
=======
  // Nyawa habis = game over, jika belum respawn di checkpoint.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
  if (nyawa <= 0) {
    ubahState(LOSE);
  } else {
    player = new Player(checkpointX + 30, lv.cpY - 90);
    cameraX = max(0, checkpointX - 300);
  }
}

<<<<<<< HEAD
// Mendeteksi event klik pada mouse dan menjalankan aksi tombol GUI sesuai layarnya
void mousePressed() {
=======
// Fungsi mousePressed: Event klik mouse: tombol dan kartu sesuai gameState.
void mousePressed() {
  // switch: aksi klik sesuai state game.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
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
<<<<<<< HEAD
    for (int i = 1; i <= 5; i++) { // Sesuaikan batas for loop dengan jumlah ketersediaan level
=======
    // Perulangan for: cek klik pada tiap kartu level.
    for (int i = 1; i <= JUMLAH_LEVEL; i++) {
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
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

<<<<<<< HEAD
// Mengatur perubahan nilai volume ketika slider ditarik/digeser oleh kursor
=======
// Fungsi mouseDragged: Event mouse digeser: mengubah volume saat slider diseret.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void mouseDragged() {
  if (sliderMenu.drag || sliderPause.drag) {
    if (gameState == MENU) sliderMenu.ubah();
    if (gameState == PAUSE) sliderPause.ubah();
  }
}

<<<<<<< HEAD
// Mereset status interaksi drag saat mouse dilepas
=======
// Fungsi mouseReleased: Event mouse dilepas: berhenti menyeret slider.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void mouseReleased() {
  sliderMenu.drag = false;
  sliderPause.drag = false;
}

<<<<<<< HEAD
// Mengatur fungsi navigasi tombol aksi pada layar post-game (menang, lanjut, ngulang)
=======
// Fungsi aksiUtama: Aksi tombol utama pada popup selesai/tamat/kalah.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void aksiUtama() {
  if (gameState == LEVEL_DONE) mulaiLevelBaru(level + 1);
  else if (gameState == WIN) mulaiGameBaru(1);
  else if (gameState == LOSE) ulangLevel();
}

<<<<<<< HEAD
// Membaca input spesifik dari keyboard pengguna
void keyPressed() {
=======
// Fungsi keyPressed: Event tombol ditekan: ESC/P pause, M mute, H aturan, ENTER/SPASI konfirmasi, A/D gerak, SPASI lompat.
void keyPressed() {
  // Tombol ESC: pause / lanjut / tutup aturan.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
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

<<<<<<< HEAD
// Membatalkan status pergerakan input saat tombol arah dilepas
=======
// Fungsi keyReleased: Event tombol dilepas: hentikan gerak.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void keyReleased() {
  if (key == 'a' || key == 'A' || keyCode == LEFT) tombolKiri = false;
  if (key == 'd' || key == 'D' || keyCode == RIGHT) tombolKanan = false;
  if (key == ' ' || key == 'w' || key == 'W' || keyCode == UP) tombolLompat = false;
}

<<<<<<< HEAD
// Memastikan pemain tidak langsung melompat atau bergerak saat masuk ke level baru
=======
// Fungsi resetInput: Mengosongkan semua status tombol agar bola tidak bergerak sendiri.
>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
void resetInput() {
  tombolKiri = false;
  tombolKanan = false;
  tombolLompat = false;
  permintaanLompat = false;
}
<<<<<<< HEAD
=======

>>>>>>> 1c5d30bc62ce79abd3a577bca9879a3b3fe2d5e3
