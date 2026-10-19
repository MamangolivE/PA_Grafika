// =====================================================
// MODUL ANTARMUKA DAN PENGENDALI UTAMA (MAIN PROGRAM)
// Menangani inisialisasi awal, loop utama permainan (mode continuous),
// serta pemanggilan fungsi rendering untuk antarmuka pengguna (GUI) dan ruang 3D.
// =====================================================
import processing.sound.*;

// Konstanta enumerasi untuk pendefinisian status layar (State Machine)
final int MENU = 0, PILIH = 1, HELP = 2, LOADING = 3, RULES = 4,
  PLAY = 5, PAUSE = 6, LEVEL_DONE = 7, WIN = 8, LOSE = 9;
  
// Batas maksimal kuantitas level yang dapat dimainkan
final int JUMLAH_LEVEL = 5;

// Struktur data koleksi dinamis (ArrayList) untuk menampung entitas-entitas di dalam arena
ArrayList<Platform> platforms = new ArrayList<Platform>();
ArrayList<Spike> spikes = new ArrayList<Spike>();
ArrayList<Coin> coins = new ArrayList<Coin>();
ArrayList<Particle> particles = new ArrayList<Particle>();

// Deklarasi instansiasi objek utama permainan
Player player;
Level lv;
EfekCuaca cuaca;

// Inisialisasi variabel pengendali alur permainan
int gameState = MENU;
int stateSebelumRules = PLAY;
int level = 1;
int nyawa = 3;
int skor = 0;
int jumlahKoin = 0;
int skorAwalLevel = 0;
int koinAwalLevel = 0;
int loadTimer = 0;

// Penetapan durasi layar pemuatan (loading) dalam hitungan frame
final int DURASI_LOADING = 150;
boolean levelDibuat = false;
boolean audioSiap = false;

// Deklarasi variabel pendukung kalkulasi grafis
float cameraX = 0;
float checkpointX = 80;
float waktuAnimasi = 0;
float kilat = 0;
float popupAnim = 0;

// Variabel berjenis boolean untuk mengevaluasi status input dari perangkat eksternal
boolean tombolKiri = false;
boolean tombolKanan = false;
boolean tombolLompat = false;
boolean permintaanLompat = false;
boolean checkpointAktif = false;

// Penetapan palet warna dasar antarmuka
color merah = color(235, 55, 45);
color cyan = color(70, 190, 65);
color ungu = color(60, 145, 235);
color gelap = color(35, 85, 45);

// Deklarasi aset media visual (latar belakang gambar, overlay, dan tipografi teks)
PImage[] imgBg = new PImage[JUMLAH_LEVEL + 1];
PImage vinyet;
PFont fontUtama;

// Prosedur inisialisasi lingkungan program yang dieksekusi secara otomatis saat program dijalankan
void setup() {
  size(1000, 650, P3D);
  smooth(4);
  frameRate(60);
  sphereDetail(24);

  fontUtama = createFont("SansSerif.bold", 32);
  textFont(fontUtama);

  // Proses iterasi untuk memuat berkas gambar latar dari ruang penyimpanan (direktori)
  String[] namaBg = {"padang.png", "salju.png", "es.png", "goa.png", "goa.png"};
  for (int i = 1; i <= JUMLAH_LEVEL; i++) {
    imgBg[i] = muatGambar(namaBg[i - 1]);
  }
  imgBg[0] = imgBg[1];
  vinyet = buatVinyet(400, 260);

  buatTombol();
  muatSemuaSfx();
  mainkanBgm(0);
  lv = infoLevel(1);
}

// Prosedur pembaruan posisi koordinat antarmuka (Responsive UI)
// Diperlukan agar tata letak elemen tetap terpusat pada resolusi layar penuh (fullscreen)
void updatePosisiUI() {
  float tengahX = width / 2.0;
  float tengahY = height / 2.0;

  btnMulai.x = tengahX - 115;
  btnMulai.y = tengahY + 40;

  btnPilih.x = tengahX - 115;
  btnPilih.y = tengahY + 102;

  btnPetunjuk.x = tengahX - 115;
  btnPetunjuk.y = tengahY + 160;

  btnKembali.x = tengahX - 110;
  btnKembali.y = height - 60;

  btnLanjut.x = tengahX - 115;
  btnLanjut.y = tengahY - 40;

  btnAturan.x = tengahX - 115;
  btnAturan.y = tengahY + 22;

  btnMenuPause.x = tengahX - 115;
  btnMenuPause.y = tengahY + 80;

  btnMulaiAturan.x = tengahX - 100;
  btnMulaiAturan.y = (height - 450) / 2.0 + 386;

  btnAksi1.x = tengahX - 115;
  btnAksi1.y = tengahY + 70;

  btnAksi2.x = tengahX - 115;
  btnAksi2.y = tengahY + 132;

  sliderMenu.x = tengahX - 90;
  sliderMenu.y = height - 50;

  sliderPause.x = tengahX - 100;
  sliderPause.y = tengahY + 170;
}

// Prosedur iterasi utama yang mengatur penyegaran layar berkelanjutan (continuous mode)
void draw() {
  updatePosisiUI(); 

  waktuAnimasi += 0.04;
  
  // Membersihkan ruang frame buffer sebelumnya untuk menghindari tumpang tindih gambar
  background(0);
  
  // Penonaktifan evaluasi kedalaman objek agar elemen GUI 2D dirender pada lapisan terdepan
  hint(DISABLE_DEPTH_TEST);

  // Mekanisme transisi grafis berdasarkan siklus state aplikasi
  switch (gameState) {
  case MENU:
    gambarMenu();
    break;
  case PILIH:
    gambarPilihLevel();
    break;
  case HELP:
    gambarPetunjuk();
    break;
  case LOADING:
    gambarLoading();
    break;
  case RULES:
    jalankanGame();
    gambarPopupAturan();
    break;
  case PLAY:
    jalankanGame();
    break;
  case PAUSE:
    jalankanGame();
    gambarOverlayPause();
    break;
  case LEVEL_DONE:
    jalankanGame();
    gambarPopupLevelSelesai();
    break;
  case WIN:
    jalankanGame();
    gambarPopupMenang();
    break;
  case LOSE:
    jalankanGame();
    gambarPopupKalah();
    break;
  }
}

// ----- CLASS EfekCuaca: Implementasi partikel visual berskala untuk efek lingkungan (hujan, salju, es, tetesan stalaktit) -----
class EfekCuaca {
  int tipe, n;
  float[] px, py, ps;

  // Konstruktor inisialisasi volume partikel serta distribusi koordinat awal secara pseudorandom
  EfekCuaca(int tipe) {
    this.tipe = tipe;
    
    switch (tipe) {
    case C_HUJAN:
      n = 220;
      break;
    case C_SALJU:
      n = 150;
      break;
    case C_ES:
      n = 100;
      break;
    case C_GOA:
      n = 22;
      break;
    default:
      n = 0;
      break;
    }
    
    px = new float[n];
    py = new float[n];
    ps = new float[n];

    int i = 0;
    while (i < n) {
      px[i] = random(width);
      py[i] = random(height);
      ps[i] = random(0.6, 1.4);
      i++;
    }
  }

  // Kalkulasi perpindahan koordinat partikel; melakukan instansiasi ulang posisi apabila melampaui batas layar
  void update() {
    for (int i = 0; i < n; i++) {
      switch (tipe) {
      case C_HUJAN:
        py[i] += 15 * ps[i];
        px[i] -= 3 * ps[i];
        break;
      case C_SALJU:
        py[i] += 1.8 * ps[i];
        px[i] += sin(waktuAnimasi * 2 + i) * 0.7 - 0.5;
        break;
      case C_ES:
        py[i] += 0.9 * ps[i];
        px[i] += sin(waktuAnimasi + i) * 0.5;
        break;
      case C_GOA:
        py[i] += 4 * ps[i];
        break;
      }

      if (py[i] > height + 10) {
        py[i] = (tipe == C_GOA) ? random(-300, -10) : -10;
        px[i] = random(width);
      }
      if (px[i] < -10) px[i] = width + 10;
      if (px[i] > width + 10) px[i] = -10;
    }
  }

  // Rendering elemen geometri 2D berdasarkan parameter klasifikasi cuaca
  void display() {
    switch (tipe) {
    case C_HUJAN:
      noStroke();
      fill(20, 30, 55, 45);
      rect(0, 0, width, height);
      stroke(200, 220, 255, 140);
      strokeWeight(1.5);
      for (int i = 0; i < n; i++) {
        line(px[i], py[i], px[i] + 3.2 * ps[i], py[i] - 16 * ps[i]);
      }
      noStroke();
      break;

    case C_SALJU:
      noStroke();
      fill(255, 255, 255, 230);
      for (int i = 0; i < n; i++) {
        ellipse(px[i], py[i], 3.5 * ps[i] + 1, 3.5 * ps[i] + 1);
      }
      break;

    case C_ES:
      noStroke();
      fill(220, 245, 255, 200);
      for (int i = 0; i < n; i++) {
        ellipse(px[i], py[i], 3 * ps[i] + 1, 3 * ps[i] + 1);
      }
      stroke(255, 255, 255, 220);
      strokeWeight(1);
      for (int i = 0; i < n; i++) {
        if ((frameCount + i * 7) % 50 < 6) {
          line(px[i] - 5, py[i], px[i] + 5, py[i]);
          line(px[i], py[i] - 5, px[i], py[i] + 5);
        }
      }
      noStroke();
      break;

    case C_GOA:
      noStroke();
      fill(130, 190, 255, 170);
      for (int i = 0; i < n; i++) {
        ellipse(px[i], py[i], 3, 9);
      }
      break;
    }
  }
}

// Kalkulasi aritmetika modulo aman untuk menggulung posisi koordinat layar
float wrap(float v, float m) {
  return ((v % m) + m) % m;
}

// Prosedur interpolasi gradien warna dari parameter warna atas ke warna bawah
void gradien(color a, color b) {
  noStroke();
  int yy = 0;
  while (yy < height) {
    fill(lerpColor(a, b, yy / (float) height));
    rect(0, yy, width, 6);
    yy += 5;
  }
}

// Pemanggilan komposisi geometri elips untuk merepresentasikan formasi awan
void awan(float g, color c, float yBase, int jumlah) {
  noStroke();
  fill(c);
  float lebarWrap = width + 300;
  float jarak = lebarWrap / jumlah;
  for (int i = 0; i < jumlah; i++) {
    float x = wrap(i * jarak - g - waktuAnimasi * 6, lebarWrap) - 150;
    float y = yBase + (i % 3) * 38;
    ellipse(x, y, 110, 40);
    ellipse(x - 32, y + 4, 60, 32);
    ellipse(x + 30, y - 10, 66, 44);
  }
}

// Eksekusi pembangunan kontur wilayah bukit melalui operasi matematika kurva Bezier
void bukit(float g, float yBase, float tinggi, float seg, color c) {
  fill(c);
  noStroke();
  int i0 = floor(g / seg);
  float x0 = i0 * seg - g;
  int n = ceil(width / seg) + 2;

  beginShape();
  vertex(x0, height);
  vertex(x0, yBase);
  for (int i = 0; i < n; i++) {
    int m = (i0 + i) % 3;
    float t = tinggi * (m == 0 ? 1.0 : (m == 1 ? 0.65 : 0.85));
    float x = x0 + i * seg;
    bezierVertex(x + seg * 0.3, yBase - t, x + seg * 0.7, yBase - t, x + seg, yBase);
  }
  vertex(x0 + n * seg, height);
  endShape(CLOSE);
}

// Implementasi segi empat kustom untuk objek kristal
void kristal(float x, float y, float s, color c) {
  noStroke();
  fill(c);
  quad(x, y - s * 1.6, x + s * 0.8, y, x, y + s * 1.2, x - s * 0.8, y);
  fill(255, 255, 255, 90);
  triangle(x, y - s * 1.6, x + s * 0.8, y, x, y);
}

// Prosedur pemanggilan logika permainan terpusat (Physics, Overlay, dan HUD)
void jalankanGame() {
  if (gameState == PLAY) {
    updateGame();
  }
  if (gameState != PAUSE) {
    cuaca.update();
  }

  gambarLatarGame();
  gambarDunia();

  if (lv.gelap) {
    gambarVinyet();
  }

  cuaca.display();

  // Pengkondisian untuk penambahan lapisan transparansi saat memicu sambaran kilat
  if (kilat > 0.02) {
    noStroke();
    fill(255, 255, 255, 150 * kilat);
    rect(0, 0, width, height);
  }

  gambarHUD();
}

// Modul seleksi logika grafis latar berdasarkan identifier level
void gambarLatarGame() {
  switch (level) {
  case 1:
    latarLevel1();
    break;
  case 2:
    latarLevel2();
    break;
  case 3:
    latarLevel3();
    break;
  case 4:
    latarLevel4();
    break;
  default:
    latarLevel5(); 
    break;
  }
}

// Prosedur untuk membangkitkan struktur grafis 3D (Z-Index rendering)
void gambarDunia() {
  // Aktivasi kalkulasi depth/Z-Buffer khusus objek dimensi ketiga
  hint(ENABLE_DEPTH_TEST);
  pushMatrix();
  
  // Penerapan skema matriks translasi yang diikat ke variabel posisi kamera virtual
  translate(-cameraX, 0);

  // Implementasi shader/pencahayaan poligon 3D
  aturCahaya();

  // Polimorfisme pemanggilan metode display() pada setiap elemen himpunan platforms
  for (Platform p : platforms) {
    p.display();
  }
  
  // Penonaktifan properti cahaya agar material sisa yang akan dirender mengadopsi pewarnaan flat
  noLights();

  for (Spike s : spikes) {
    s.display();
  }

  pushMatrix();
  // Pemindahan sumbu ordinat Z ke garis depan untuk memastikan geometri koin tidak mengalami oklusi visual
  translate(0, 0, 40);
  for (Coin c : coins) {
    c.display();
  }
  gambarCheckpoint();
  gambarPortal();
  player.display();
  
  for (Particle p : particles) {
    p.display();
  }
  popMatrix();

  popMatrix();
  
  // Dekonfigurasi fungsi Depth Test saat objek 3D usai di-render
  hint(DISABLE_DEPTH_TEST);
}

// Konfigurasi sistem pencahayaan ruang geometris menggunakan lampu direksional maupun titik sorot lokal
void aturCahaya() {
  if (lv.gelap) {
    ambientLight(red(lv.cAmbient), green(lv.cAmbient), blue(lv.cAmbient));
    lightFalloff(0.55, 0.0, 0.000035);
    pointLight(255, 205, 140, player.x, player.y - 15, 150);
  } else {
    lightFalloff(1, 0, 0);
    ambientLight(red(lv.cAmbient), green(lv.cAmbient), blue(lv.cAmbient));
    directionalLight(red(lv.cSinar), green(lv.cSinar), blue(lv.cSinar), -0.4, 0.6, -1);
  }
}

// Kalkulasi manipulasi nilai matriks piksel gambar ARGB untuk efek vinyet sudut (radius kegelapan)
PImage buatVinyet(int w, int h) {
  PImage im = createImage(w, h, ARGB);
  im.loadPixels();
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      float d = dist(x, y, w / 2.0, h / 2.0) / (w / 2.0);
      float a = constrain(map(d, 0.18, 0.9, 0, 235), 0, 235);
      im.pixels[y * w + x] = color(4, 6, 16, a);
    }
  }
  im.updatePixels();
  return im;
}

// Prosedur memproyeksikan vinyet berpusat pada koordinat aktual pemain
void gambarVinyet() {
  float sx = player.x - cameraX;
  float sy = player.y;
  imageMode(CENTER);
  tint(255, 238 + sin(waktuAnimasi * 7) * 14);
  image(vinyet, sx, sy, 1800, 1170);
  noTint();
  imageMode(CORNER);
}

// Konstruksi model hati menggunakan pemanggilan geometri kurva
void hati(float x, float y, float s) {
  beginShape();
  vertex(x, y + s * 0.6);
  bezierVertex(x - s, y - s * 0.1, x - s * 0.5, y - s * 0.9, x, y - s * 0.3);
  bezierVertex(x + s * 0.5, y - s * 0.9, x + s, y - s * 0.1, x, y + s * 0.6);
  endShape(CLOSE);
}

// Merender panel tampilan informasi tambahan bagi pemain (Heads-Up Display)
void gambarHUD() {
  noStroke();
  fill(255, 255, 235, 235);
  rect(15, 15, 340, 72, 12);

  fill(35, 85, 45);
  textAlign(LEFT, CENTER);
  textSize(14);
  text("LEVEL " + level + " - " + lv.nama, 30, 33);

  // Proses iterasi dalam menampilkan sisa nyawa aktif
  for (int i = 0; i < 3; i++) {
    if (i < nyawa) fill(225, 50, 55);
    else fill(190, 190, 180);
    hati(40 + i * 28, 64, 10);
  }

  fill(35, 85, 45);
  textSize(15);
  text("SKOR " + skor, 140, 64);
  fill(180, 130, 20);
  text("KOIN " + jumlahKoin, 250, 64);

  fill(255, 255, 245, 225);
  rect(width - 330, 15, 315, 34, 9);
  fill(35, 85, 45);
  textAlign(CENTER, CENTER);
  textSize(12);
  text("P : PAUSE  |  H : ATURAN  |  M : " + (senyap ? "SUARA ON" : "MUTE"), width - 172, 32);

  fill(255, 255, 245, 225);
  rect(width - 280, height - 58, 265, 43, 9);
  fill(35, 85, 45);
  text("A / D : GERAK   |   SPASI : LOMPAT", width - 147, height - 36);
}

// Pembangunan properti fisik objek bendera checkpoint
void gambarCheckpoint() {
  float x = lv.cpX;
  float y = lv.cpY;

  pushMatrix();
  translate(x, y - 30, 0);
  noStroke();
  fill(115, 85, 45);
  box(6, 60, 6);
  popMatrix();

  // Pengaturan fluktuasi sudut berkibarnya bendera menggunakan besaran gelombang periodik
  float y0 = y - 58;
  float k = sin(waktuAnimasi * 4) * 5;
  fill(checkpointAktif ? color(255, 220, 40) : color(230, 70, 55));
  beginShape();
  vertex(x, y0);
  bezierVertex(x + 12, y0 + k, x + 24, y0 - k, x + 38, y0 + 10);
  bezierVertex(x + 24, y0 + 14 - k, x + 12, y0 + 14 + k, x, y0 + 26);
  endShape(CLOSE);
}

// Implementasi animasi geometri statis (cincin perantara) untuk merepresentasikan gerbang penyelesaian 
void gambarPortal() {
  float x = lv.lebar - 100;
  float y = lv.exitY;

  pushMatrix();
  translate(x, y, 0);
  noStroke();
  fill(100, 230, 95, 70 + sin(waktuAnimasi * 3) * 25);
  ellipse(0, 0, 58, 74);

  noFill();
  strokeWeight(4);
  for (int i = 0; i < 4; i++) {
    pushMatrix();
    rotateY(waktuAnimasi * 1.5 + i * HALF_PI / 2);
    stroke(40, 190 + i * 15, 75);
    ellipse(0, 0, 62, 78);
    popMatrix();
  }
  noStroke();
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(12);
  text("EXIT", 0, 1);
  popMatrix();
}

// ----- CLASS Tombol: Implementasi entitas GUI dengan sistem deteksi persilangan koordinat pointer -----
class Tombol {
  float x, y, w, h;
  String label;
  color warna;

  Tombol(float x, float y, float w, float h, String label, color warna) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.warna = warna;
  }

  // Mengembalikan luaran logika boolean positif apabila irisan kursor terdeteksi (hover mechanic)
  boolean hover() {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  // Rendering tombol dengan integrasi indikator seleksi warna sekunder
  void display() {
    boolean hv = hover();
    noStroke();
    if (hv) {
      fill(red(warna), green(warna), blue(warna), 70);
      rect(x - 4, y - 4, w + 8, h + 8, 13);
      fill(warna);
    } else {
      fill(255, 255, 235);
    }
    rect(x, y, w, h, 10);

    noFill();
    stroke(warna);
    strokeWeight(hv ? 2.5 : 1.5);
    rect(x, y, w, h, 10);

    noStroke();
    fill(35, 85, 45);
    textAlign(CENTER, CENTER);
    textSize(15);
    text(label, x + w / 2, y + h / 2);
  }
}

// ----- CLASS GeserVolume: Implementasi slider parameter audio yang diikat ke posisi klik-tarik kursor -----
class GeserVolume {
  float x, y, w;
  boolean drag = false;

  GeserVolume(float x, float y, float w) {
    this.x = x;
    this.y = y;
    this.w = w;
  }

  // Evaluasi bounding box untuk mendeteksi intensi modifikasi kontrol volume
  boolean kena() {
    return mouseX >= x - 12 && mouseX <= x + w + 12 && mouseY >= y - 14 && mouseY <= y + 14;
  }

  // Rutin pemrosesan awal penekanan slider
  void tekan() {
    if (kena()) {
      drag = true;
      ubah();
    }
  }

  // Menyesuaikan rasio interval koordinat tuas yang dipetakan menjadi faktor amplitude frekuensi
  void ubah() {
    volume = constrain((mouseX - x) / w, 0, 1);
    terapkanVolume();
  }

  // Rendering elemen latar panjang dan bulatan penanda volume
  void display() {
    noStroke();
    fill(35, 85, 45);
    textAlign(CENTER, CENTER);
    textSize(12);
    text("VOLUME  " + round(volume * 100) + "%" + (senyap ? "  (MUTE)" : ""), x + w / 2, y - 16);

    fill(200, 210, 190);
    rect(x, y - 3, w, 6, 3);
    fill(cyan);
    rect(x, y - 3, w * volume, 6, 3);
    fill(255);
    stroke(cyan);
    strokeWeight(2);
    ellipse(x + w * volume, y, 16, 16);
    noStroke();
  }
}

// Deklarasi alokasi kelas instansiasi antarmuka pendukung
Tombol btnMulai, btnPilih, btnPetunjuk, btnKembali;
Tombol btnLanjut, btnAturan, btnMenuPause;
Tombol btnMulaiAturan, btnAksi1, btnAksi2;
GeserVolume sliderMenu, sliderPause;

// Melakukan passing parameter dasar pada kelas tombol; modifikasi letak absolut akan ditangani oleh updatePosisiUI()
void buatTombol() {
  btnMulai = new Tombol(width / 2 - 115, 365, 230, 50, "MULAI BERMAIN", cyan);
  btnPilih = new Tombol(width / 2 - 115, 427, 230, 46, "PILIH LEVEL", ungu);
  btnPetunjuk = new Tombol(width / 2 - 115, 485, 230, 46, "PETUNJUK", ungu);
  btnKembali = new Tombol(width / 2 - 110, 590, 220, 44, "KEMBALI", cyan);

  btnLanjut = new Tombol(width / 2 - 115, 285, 230, 50, "LANJUTKAN", cyan);
  btnAturan = new Tombol(width / 2 - 115, 347, 230, 46, "ATURAN LEVEL", ungu);
  btnMenuPause = new Tombol(width / 2 - 115, 405, 230, 46, "MENU UTAMA", ungu);

  btnMulaiAturan = new Tombol(width / 2 - 100, 105 + 450 - 64, 200, 46, "MULAI", cyan);
  btnAksi1 = new Tombol(width / 2 - 115, 395, 230, 50, "", cyan);
  btnAksi2 = new Tombol(width / 2 - 115, 457, 230, 46, "MENU UTAMA", ungu);

  sliderMenu = new GeserVolume(width / 2 - 90, 600, 180);
  sliderPause = new GeserVolume(width / 2 - 100, 495, 200);
}

// Menjalankan efek interpolasi pada matriks skala secara bertahap saat antarmuka popup dipanggil
void mulaiTransformPopup() {
  popupAnim = lerp(popupAnim, 1, 0.2);
  noStroke();
  fill(0, 0, 0, 150 * popupAnim);
  rect(0, 0, width, height);
  pushMatrix();
  translate(width / 2, height / 2);
  scale(0.8 + 0.2 * popupAnim);
  translate(-width / 2, -height / 2);
}

// Pembuatan struktur arsitektur panel pelapis latar (backdrop window)
void panel(float x, float y, float w, float h, String judul, color aksen) {
  noStroke();
  fill(0, 0, 0, 60);
  rect(x + 6, y + 8, w, h, 20);
  fill(255, 255, 245, 245);
  rect(x, y, w, h, 20);
  fill(aksen);
  rect(x, y, w, 54, 20, 20, 0, 0);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(22);
  text(judul, x + w / 2, y + 27);
}

// Render representasi ringkas dari tingkat kesulitan level ke dalam wujud grafis dua dimensi
void gambarBanner(int idx, float x, float y, float w, float h) {
  Level L = infoLevel(constrain(idx, 1, JUMLAH_LEVEL));
  noStroke();
  
  for (int i = 0; i < h; i += 4) {
    fill(lerpColor(L.langitA, L.langitB, i / h));
    rect(x, y + i, w, 4);
  }
  
  fill(L.cTanah);
  rect(x, y + h * 0.78, w, h * 0.22);
  fill(L.cAtas);
  rect(x, y + h * 0.78, w, h * 0.06);
  fill(L.cTanah);
  rect(x + w * 0.62, y + h * 0.6, w * 0.25, h * 0.08);
  fill(L.cAtas);
  rect(x + w * 0.62, y + h * 0.6, w * 0.25, h * 0.03);
  fill(240, 90, 70);
  
  for (int i = 0; i < 3; i++) {
    float sx = x + w * 0.12 + i * 14;
    triangle(sx, y + h * 0.78, sx + 7, y + h * 0.78 - 16, sx + 14, y + h * 0.78);
  }
  
  fill(255, 205, 35);
  ellipse(x + w * 0.74, y + h * 0.5, 14, 14);
  bolaHias(x + w * 0.4, y + h * 0.78 - 16, 16);
  noFill();
  stroke(35, 85, 45);
  strokeWeight(2);
  rect(x, y, w, h, 6);
  noStroke();
}

// Integrasi rendering teks dan tombol untuk mencetak pedoman informasi aturan level saat ini
void gambarPopupAturan() {
  mulaiTransformPopup();
  float w = 660, h = 450, x = (width - w) / 2.0, y = (height - h) / 2.0;
  panel(x, y, w, h, "LEVEL " + level + "  -  " + lv.nama, lv.cAtas == color(245, 250, 255) ? ungu : darker(lv.cAtas));

  gambarBanner(level, x + 28, y + 74, 220, 124);

  fill(35, 85, 45);
  textAlign(LEFT, TOP);
  textSize(15);
  text("MISI", x + 268, y + 74);
  fill(50, 90, 60);
  textSize(14);
  text(lv.tujuan, x + 268, y + 98, w - 296, 100);

  fill(35, 85, 45);
  textSize(15);
  text("ATURAN", x + 28, y + 216);
  textSize(14);
  fill(50, 90, 60);
  
  for (int i = 0; i < lv.aturan.length; i++) {
    text("-  " + lv.aturan[i], x + 28, y + 242 + i * 28, w - 56, 28);
  }

  fill(110, 130, 110);
  textAlign(CENTER, CENTER);
  textSize(12);
  text("A / D gerak  |  SPASI lompat  |  P pause  |  M suara  |  H buka aturan", x + w / 2.0, y + h - 80);

  btnMulaiAturan.label = (stateSebelumRules == PAUSE) ? "KEMBALI" : "MULAI";
  btnMulaiAturan.display();
  popMatrix();
}

// Menghasilkan keluaran matriks warna baru dengan nilai intensitas kecerahan yang direduksi
color darker(color c) {
  return color(red(c) * 0.6, green(c) * 0.6, blue(c) * 0.6);
}

// Menampilkan popup penghentian layar sementara (jeda)
void gambarOverlayPause() {
  mulaiTransformPopup();
  float tengahX = width / 2.0;
  float tengahY = height / 2.0;
  panel(tengahX - 170, tengahY - 170, 340, 340, "PAUSE", ungu);
  btnLanjut.display();
  btnAturan.display();
  btnMenuPause.display();
  sliderPause.display();
  popMatrix();
}

// Mencetak data pasca-eksekusi mengenai statistik variabel internal usai menyelesaikan sebuah level
void gambarPopupLevelSelesai() {
  mulaiTransformPopup();
  float tengahX = width / 2.0;
  float tengahY = height / 2.0;
  panel(tengahX - 200, tengahY - 195, 400, 400, "LEVEL " + level + " SELESAI!", color(45, 160, 60));
  fill(35, 85, 45);
  textAlign(CENTER, CENTER);
  textSize(18);
  text(lv.nama, tengahX, tengahY - 110);
  textSize(17);
  text("Koin level ini : " + (jumlahKoin - koinAwalLevel), tengahX, tengahY - 70);
  text("Bonus selesai : +500", tengahX, tengahY - 40);
  text("Nyawa tersisa : " + nyawa, tengahX, tengahY - 10);
  fill(180, 130, 20);
  textSize(22);
  text("SKOR  " + skor, tengahX, tengahY + 30);
  btnAksi1.label = "LEVEL BERIKUTNYA";
  btnAksi1.display();
  btnAksi2.display();
  popMatrix();
}

// Menampilkan indikator akhir perangkat lunak ketika variabel jumlah level maksimum telah terlampaui
void gambarPopupMenang() {
  mulaiTransformPopup();
  float tengahX = width / 2.0;
  float tengahY = height / 2.0;
  panel(tengahX - 220, tengahY - 205, 440, 420, "SELAMAT! BOUNCE TAMAT", color(230, 160, 20));
  fill(35, 85, 45);
  textAlign(CENTER, CENTER);
  textSize(17);
  text("Anda telah menyelesaikan seluruh " + JUMLAH_LEVEL + " level:", tengahX, tengahY - 115);
  text("Padang Hujan, Salju, Istana Es,", tengahX, tengahY - 87);
  text("Goa Kristal, dan Kawah Lava.", tengahX, tengahY - 63);
  text("Total koin : " + jumlahKoin, tengahX, tengahY - 20);
  fill(180, 130, 20);
  textSize(24);
  text("SKOR AKHIR  " + skor, tengahX, tengahY + 20);
  btnAksi1.label = "MAIN LAGI";
  btnAksi1.display();
  btnAksi2.display();
  popMatrix();
}

// Menampilkan pesan umpan balik atas kekalahan dan opsi instansiasi pengulangan state
void gambarPopupKalah() {
  mulaiTransformPopup();
  float tengahX = width / 2.0;
  float tengahY = height / 2.0;
  panel(tengahX - 200, tengahY - 175, 400, 360, "GAME OVER", color(215, 55, 45));
  fill(35, 85, 45);
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Nyawa terkuras habis di level " + level + " - " + lv.nama, tengahX, tengahY - 90);
  textSize(21);
  text("Perolehan Skor : " + skor, tengahX, tengahY - 40);
  btnAksi1.label = "COBA LAGI";
  btnAksi1.display();
  btnAksi2.display();
  popMatrix();
}

// Memuat sumber grafika yang akan digunakan sebagai latar antarmuka menu
void latarMenu() {
  gambarBg(0, waktuAnimasi * 25, color(100, 180, 255), color(215, 240, 255));
}

// Pembentukan prototipe entitas bola untuk tujuan hiasan elemen antarmuka statis
void bolaHias(float x, float y, float r) {
  noStroke();
  fill(0, 0, 0, 40);
  ellipse(x, 600, r * 1.6, 8);
  fill(195, 35, 35);
  ellipse(x, y, r * 2, r * 2);
  fill(235, 55, 45);
  ellipse(x - 2, y - 2, r * 1.75, r * 1.75);
  fill(255, 150, 125, 190);
  ellipse(x - r * 0.35, y - r * 0.4, r * 0.3, r * 0.3);
}

// Prosedur pemanggilan blok rendering untuk layar orientasi awal permainan
void gambarMenu() {
  latarMenu();
  float tengahX = width / 2.0;
  float tengahY = height / 2.0;

  float bx = wrap(waktuAnimasi * 70, width + 100) - 50;
  float by = height - 60 - abs(sin(waktuAnimasi * 3)) * 140;
  bolaHias(bx, by, 22);

  float ly = tengahY - 135 + sin(waktuAnimasi * 2) * 5;
  textAlign(CENTER, CENTER);
  textSize(76);
  fill(20, 70, 30);
  text("BOUNCE", tengahX + 4, ly + 5);
  fill(60, 185, 70);
  text("BOUNCE", tengahX, ly);

  textAlign(CENTER, CENTER);
  fill(35, 110, 55);
  textSize(18);
  text("PETUALANGAN 5 DUNIA", tengahX, tengahY - 13);

  btnMulai.display();
  btnPilih.display();
  btnPetunjuk.display();

  fill(40, 100, 55);
  textSize(12);
  text("FINAL PROJECT - COMPUTER GRAPHICS  |  PROCESSING JAVA MODE", tengahX, height - 90);
  sliderMenu.display();
}

// Memuat pedoman pengoperasian parameter kontrol dalam tata letak tabular kustom
void gambarPetunjuk() {
  latarMenu();
  float tengahX = width / 2.0;
  float tengahY = height / 2.0;

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(36);
  text("CARA BERMAIN", tengahX, tengahY - 275);

  noStroke();
  fill(255, 255, 245, 235);
  float boxX = (width - 740) / 2.0; 
  rect(boxX, tengahY - 240, 740, 250, 18);

  fill(35, 105, 50);
  textSize(20);
  text("KONTROL", tengahX, tengahY - 215);

  textAlign(LEFT, CENTER);
  fill(35, 75, 45);
  textSize(16);
  String[][] kontrol = {
    {"A / D atau panah kiri / kanan", "Bergerak ke kiri dan kanan"},
    {"SPASI / W / panah atas", "Melompat"},
    {"P / ESC", "Jeda atau lanjutkan"},
    {"H", "Buka aturan level"},
    {"M", "Suara on / mute"},
    {"MOUSE", "Memilih tombol dan mengatur volume"}
  };
  
  for (int i = 0; i < kontrol.length; i++) {
    text(kontrol[i][0], boxX + 40, tengahY - 177 + i * 30);
    text(kontrol[i][1], boxX + 340, tengahY - 177 + i * 30);
  }

  noStroke();
  fill(255, 255, 245, 235);
  rect(boxX, tengahY + 25, 740, 220, 18);

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(20);
  text("DUNIA & BAHAYA", tengahX, tengahY + 50);

  fill(35, 75, 45);
  textSize(15);
  text("Level 1 Padang Hujan  -  Level 2 Gunung Salju (licin)", tengahX, tengahY + 85);
  text("Level 3 Istana Es (sangat licin, platform bergerak)  -  Level 4 Goa Kristal (gelap)", tengahX, tengahY + 113);
  text("Level 5 Kawah Lava (Duri sepanjang jalan). Jatuh/Kena Duri = kurang nyawa.", tengahX, tengahY + 151);
  text("Koin +100, checkpoint +250, selesai level +500. Capai portal hijau di ujung level.", tengahX, tengahY + 179);
  text("Setiap level memiliki muatan awal (loading) dan antarmuka aturan secara independen.", tengahX, tengahY + 207);

  btnKembali.display();
}

// Memvisualisasikan opsi menu navigasi level dinamis memanfaatkan pemetaan koordinat terstruktur
void gambarPilihLevel() {
  latarMenu();
  float tengahX = width / 2.0;
  float tengahY = height / 2.0;

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(36);
  text("PILIH LEVEL", tengahX, tengahY - 255);

  pushMatrix();
  float totalLebar = (JUMLAH_LEVEL * 205 - 15) * 0.85; 
  float startX = (width - totalLebar) / 2.0;             
  float startY = (height - 340 * 0.85) / 2.0;

  translate(startX, startY);
  scale(0.85); 

  for (int i = 1; i <= JUMLAH_LEVEL; i++) {
    float x = (i - 1) * 205;
    float y = 0;

    boolean hv = mouseX >= (x * 0.85 + startX) && mouseX <= ((x + 190) * 0.85 + startX) && mouseY >= startY && mouseY <= (340 * 0.85 + startY);

    Level L = infoLevel(i);

    noStroke();
    fill(0, 0, 0, 50);
    rect(x + 4, y + 6, 190, 340, 16);
    fill(hv ? color(255, 255, 215) : color(255, 255, 245));
    rect(x, y, 190, 340, 16);
    noFill();
    stroke(hv ? cyan : color(120, 170, 120));
    strokeWeight(hv ? 3 : 1.5);
    rect(x, y, 190, 340, 16);

    gambarBanner(i, x + 10, y + 10, 170, 108);

    fill(35, 105, 50);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("LEVEL " + i, x + 95, y + 140);
    textSize(17);
    text(L.nama, x + 95, y + 165);

    fill(60, 100, 70);
    textSize(11);
    textAlign(CENTER, TOP);
    text(L.tujuan, x + 14, y + 190, 162, 90);

    fill(hv ? cyan : color(215, 235, 215));
    noStroke();
    rect(x + 20, y + 290, 150, 32, 10);
    fill(35, 85, 45);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("MAIN", x + 95, y + 306);

    if (hv && mousePressed && gameState == PILIH) {
        klik();
        mulaiGameBaru(i);
        gameState = LOADING;
    }
  }
  popMatrix();

  btnKembali.display();
}

// Fungsi dummy sebagai pencegahan error pemanggilan referensi usang
boolean kartuHover(int i) {
  return false;
}

// Manajemen simulasi layar pra-muat grafis serta alokasi data audio ke memori sementara
void gambarLoading() {
  loadTimer++;
  float p = constrain(loadTimer / (float) DURASI_LOADING, 0, 1);

  String pesan = "Menyiapkan dunia...";
  
  // Penyisipan instruksi eksekusi instansiasi tingkat awal
  if (p >= 0.35 && !levelDibuat) {
    buatLevel();
    levelDibuat = true;
  }
  
  // Penyisipan instruksi pengikatan (binding) trek musik latar
  if (p >= 0.7 && !audioSiap) {
    mainkanBgm(lv.indexBgm);
    audioSiap = true;
  }
  if (p >= 0.35) pesan = "Membangun level...";
  if (p >= 0.7) pesan = "Memuat audio...";

  gambarBg(level, waktuAnimasi * 30, lv.langitA, lv.langitB);
  noStroke();

  float tengahX = width / 2.0;
  float tengahY = height / 2.0;

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(20);
  text("LEVEL " + level, tengahX, tengahY - 265);
  textSize(46);
  text(lv.nama, tengahX, tengahY - 220);

  gambarBanner(level, tengahX - 220, tengahY - 175, 440, 250);

  float bx = tengahX - 250, by = tengahY + 145, bw = 500, bh = 22;
  noStroke();
  fill(0, 0, 0, 90);
  rect(bx - 4, by - 4, bw + 8, bh + 8, 14);
  fill(255, 255, 255, 80);
  rect(bx, by, bw, bh, 10);
  fill(lv.cAtas);
  rect(bx, by, bw * p, bh, 10);

  bolaHias(bx + bw * p, by - 16 - abs(sin(waktuAnimasi * 6)) * 14, 11);

  fill(255);
  textSize(15);
  text(pesan + "  " + floor(p * 100) + "%", tengahX, by + 48);
  textSize(13);
  fill(255, 255, 255, 220);
  text(lv.tip, tengahX, by + 80);

  if (loadTimer >= DURASI_LOADING && levelDibuat) {
    stateSebelumRules = PLAY;
    ubahState(RULES);
  }
}

// Pemetaan ruang deklaratif pustaka pustaka manipulasi suara
SoundFile sfxLompat, sfxKoin, sfxKena, sfxCheckpoint, sfxMenang, sfxKlik;
SoundFile[] bgm = new SoundFile[JUMLAH_LEVEL + 1];

// Direktori kueri pemanggilan file suara kompresi tanpa rugi (lossless audio)
String[] namaBgm = {
  "bgm_menu.wav", "bgm_level1.wav", "bgm_level2.wav", "bgm_level3.wav", "bgm_level4.wav", "bgm_level4.wav"
};

float volume = 0.6;
boolean senyap = false;
int bgmAktif = -1;

// Modul utilitas penarik file sumber suara; implementasi penanganan galat (exception handling)
SoundFile muatSuara(String nama) {
  try {
    File f = new File(dataPath("audio/" + nama));
    if (!f.exists()) {
      println("Audio tidak ditemukan: " + nama);
      return null;
    }
    return new SoundFile(this, "audio/" + nama);
  }
  catch (Exception e) {
    println("Gagal memuat audio: " + nama);
    return null;
  }
}

// Modul utilitas penarik file citra digital; mencegah interupsi kegagalan memori saat gambar tidak eksis
PImage muatGambar(String nama) {
  File f = new File(dataPath("image/" + nama));
  if (!f.exists()) {
    println("Gambar tidak ditemukan: " + nama);
    return null;
  }
  return loadImage("image/" + nama);
}

// Agregasi rutin pemuatan berkas aset suara spesifik menjadi bentuk himpunan utilitas
void muatSemuaSfx() {
  sfxLompat = muatSuara("lompat.wav");
  sfxKoin = muatSuara("koin.wav");
  sfxKena = muatSuara("kena.wav");
  sfxCheckpoint = muatSuara("checkpoint.wav");
  sfxMenang = muatSuara("menang.wav");
  sfxKlik = muatSuara("klik.wav");
}

// Memutar umpan balik indera pendengaran satu kali menggunakan nilai skalar (volume) yang diregulasi
void mainkanSfx(SoundFile s) {
  if (s == null || senyap) return;
  s.amp(volume);
  s.play();
}

// Eksekusi pemanggilan suara taktil efek mekanis dari UI
void klik() {
  mainkanSfx(sfxKlik);
}

// Aktivasi pemutaran aliran lagu secara berulang-ulang melalui indeks saluran (channel) audio
void mainkanBgm(int i) {
  if (bgmAktif == i) return;
  hentikanBgm();
  if (bgm[i] == null) bgm[i] = muatSuara(namaBgm[i]);
  bgmAktif = i;
  if (bgm[i] != null) {
    bgm[i].loop();
    bgm[i].amp(senyap ? 0 : volume * 0.5);
  }
}

// Pemutusan pemutaran modul audio pada siklus aktif sebelum pengoperasian ke saluran lain
void hentikanBgm() {
  if (bgmAktif >= 0 && bgm[bgmAktif] != null) {
    bgm[bgmAktif].stop();
  }
  bgmAktif = -1;
}

// Fungsi pembaruan masukan mutasi penguatan volume sesuai slider referensi
void terapkanVolume() {
  if (bgmAktif >= 0 && bgm[bgmAktif] != null) {
    bgm[bgmAktif].amp(senyap ? 0 : volume * 0.5);
  }
}

// Rendering lapisan grafika pemandangan paralaks (Parallax Scrolling) dengan pencerminan skala (scale -1) 
void gambarBg(int idx, float geser, color a, color b) {
  PImage im = imgBg[idx];
  if (im == null) {
    gradien(a, b);
    return;
  }
  float w = im.width * (height / (float) im.height);
  int n = floor(geser / w);
  float x = -(geser - n * w);
  int i = 0;
  
  while (x < width) {
    if ((n + i) % 2 != 0) {
      pushMatrix();
      translate(x + w, 0);
      scale(-1, 1);
      image(im, 0, 0, w, height);
      popMatrix();
    } else {
      image(im, x, 0, w, height);
    }
    x += w;
    i++;
  }
}
