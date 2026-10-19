// Main Filenya
import processing.sound.*;

// STATE GAME: tiap angka mewakili satu layar/kondisi permainan.
final int MENU = 0, PILIH = 1, HELP = 2, LOADING = 3, RULES = 4,
  PLAY = 5, PAUSE = 6, LEVEL_DONE = 7, WIN = 8, LOSE = 9;
// Jumlah level (Sudah diubah jadi 5).
final int JUMLAH_LEVEL = 5;

// Daftar objek dunia (ArrayList): platform, duri, koin, dan partikel.
ArrayList<Platform> platforms = new ArrayList<Platform>();
ArrayList<Spike> spikes = new ArrayList<Spike>();
ArrayList<Coin> coins = new ArrayList<Coin>();
ArrayList<Particle> particles = new ArrayList<Particle>();

// Objek utama: pemain, data level aktif, dan cuaca aktif.
Player player;
Level lv;
EfekCuaca cuaca;

// Variabel permainan: state, level, nyawa, skor, koin, dan loading.
int gameState = MENU;
int stateSebelumRules = PLAY;
int level = 1;
int nyawa = 3;
int skor = 0;
int jumlahKoin = 0;
int skorAwalLevel = 0;
int koinAwalLevel = 0;
int loadTimer = 0;
// Lama loading dalam frame.
final int DURASI_LOADING = 150;
boolean levelDibuat = false;
boolean audioSiap = false;

// Posisi kamera, waktu animasi, kilatan petir, dan animasi popup.
float cameraX = 0;
float checkpointX = 80;
float waktuAnimasi = 0;
float kilat = 0;
float popupAnim = 0;

// Status tombol keyboard dan checkpoint.
boolean tombolKiri = false;
boolean tombolKanan = false;
boolean tombolLompat = false;
boolean permintaanLompat = false;
boolean checkpointAktif = false;

// Warna tema yang dipakai di banyak tempat.
color merah = color(235, 55, 45);
color cyan = color(70, 190, 65);
color ungu = color(60, 145, 235);
color gelap = color(35, 85, 45);

// Gambar background (data/image/bg1.png ... bg4.png), vinyet goa, dan font.
PImage[] imgBg = new PImage[JUMLAH_LEVEL + 1];
PImage vinyet;
PFont fontUtama;

// Fungsi setup: Dipanggil sekali saat program mulai: atur jendela P3D, font, muat gambar background, buat tombol, muat suara, putar musik menu.
void setup() {
  size(1000, 650, P3D);
  smooth(4);
  frameRate(60);
  sphereDetail(24);

  fontUtama = createFont("SansSerif.bold", 32);
  textFont(fontUtama);

  // Perulangan for: muat background (Sudah ditambah background dummy untuk level 5)
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

// Fungsi updatePosisiUI: Menjaga posisi semua tombol dan slider tetap di tengah layar jika di-fullscreen.
void updatePosisiUI() {
  btnMulai.x = width / 2 - 115;
  btnPilih.x = width / 2 - 115;
  btnPetunjuk.x = width / 2 - 115;
  btnKembali.x = width / 2 - 110;

  btnLanjut.x = width / 2 - 115;
  btnAturan.x = width / 2 - 115;
  btnMenuPause.x = width / 2 - 115;

  btnMulaiAturan.x = width / 2 - 100;
  // Perbaikan posisi Y tombol Mulai agar dinamis mengikuti tinggi panel saat fullscreen
  btnMulaiAturan.y = (height - 450) / 2 + 386; 

  btnAksi1.x = width / 2 - 115;
  btnAksi2.x = width / 2 - 115;

  sliderMenu.x = width / 2 - 90;
  sliderPause.x = width / 2 - 100;
}

// Fungsi draw: Dipanggil terus menerus (mode continuous, 60x/detik). Memilih layar yang digambar sesuai gameState.
void draw() {
  updatePosisiUI(); // Panggil update posisi agar menu selalu rapi di tengah

  waktuAnimasi += 0.04;
  // Bersihkan layar dan depth buffer.
  background(0);
  // Matikan depth test agar gambar 2D (latar, HUD) tidak saling menutupi.
  hint(DISABLE_DEPTH_TEST);

  // switch: pilih layar sesuai state game.
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

// ----- CLASS EfekCuaca: partikel cuaca layar (hujan, salju, serpihan es, tetesan goa) dengan array posisi/ukuran. -----
class EfekCuaca {
  int tipe, n;
  float[] px, py, ps;

  // Konstruktor: tentukan jumlah partikel sesuai tipe cuaca lalu sebar posisi awal secara acak.
  EfekCuaca(int tipe) {
    this.tipe = tipe;
    // switch: tentukan jumlah partikel menurut tipe cuaca.
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
    // Perulangan while: isi posisi acak setiap partikel.
    while (i < n) {
      px[i] = random(width);
      py[i] = random(height);
      ps[i] = random(0.6, 1.4);
      i++;
    }
  }

  // Menggerakkan semua partikel cuaca; partikel yang keluar layar dipindah ke sisi seberang.
  void update() {
    // Perulangan for: gerakkan setiap partikel.
    for (int i = 0; i < n; i++) {
      // switch: arah dan kecepatan gerak tiap tipe cuaca.
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

  // Menggambar cuaca: garis untuk hujan, lingkaran untuk salju/es, lonjong untuk tetesan goa.
  void display() {
    // switch: cara menggambar tiap tipe cuaca.
    switch (tipe) {
    case C_HUJAN:
      noStroke();
      fill(20, 30, 55, 45);
      rect(0, 0, width, height);
      stroke(200, 220, 255, 140);
      strokeWeight(1.5);
      // Perulangan for: gambar garis hujan.
      for (int i = 0; i < n; i++) {
        line(px[i], py[i], px[i] + 3.2 * ps[i], py[i] - 16 * ps[i]);
      }
      noStroke();
      break;

    case C_SALJU:
      noStroke();
      fill(255, 255, 255, 230);
      // Perulangan for: gambar butir salju.
      for (int i = 0; i < n; i++) {
        ellipse(px[i], py[i], 3.5 * ps[i] + 1, 3.5 * ps[i] + 1);
      }
      break;

    case C_ES:
      noStroke();
      fill(220, 245, 255, 200);
      // Perulangan for: gambar butir es.
      for (int i = 0; i < n; i++) {
        ellipse(px[i], py[i], 3 * ps[i] + 1, 3 * ps[i] + 1);
      }
      stroke(255, 255, 255, 220);
      strokeWeight(1);
      // Perulangan for: gambar kilau silang pada es.
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
      // Perulangan for: gambar tetesan goa.
      for (int i = 0; i < n; i++) {
        ellipse(px[i], py[i], 3, 9);
      }
      break;
    }
  }
}

// Fungsi wrap: Modulo yang aman untuk angka negatif; dipakai untuk menggulung posisi awan/background.
float wrap(float v, float m) {
  return ((v % m) + m) % m;
}

// Fungsi gradien: Mengisi layar dengan gradasi warna vertikal (cadangan jika gambar background tidak ada).
void gradien(color a, color b) {
  noStroke();
  int yy = 0;
  // Perulangan while: gambar strip warna dari atas ke bawah.
  while (yy < height) {
    fill(lerpColor(a, b, yy / (float) height));
    rect(0, yy, width, 6);
    yy += 5;
  }
}

// Fungsi awan: Menggambar awan bergerak dari beberapa ellipse (bentuk dasar).
void awan(float g, color c, float yBase, int jumlah) {
  noStroke();
  fill(c);
  float lebarWrap = width + 300;
  float jarak = lebarWrap / jumlah;
  // Perulangan for: gambar tiap awan.
  for (int i = 0; i < jumlah; i++) {
    float x = wrap(i * jarak - g - waktuAnimasi * 6, lebarWrap) - 150;
    float y = yBase + (i % 3) * 38;
    ellipse(x, y, 110, 40);
    ellipse(x - 32, y + 4, 60, 32);
    ellipse(x + 30, y - 10, 66, 44);
  }
}

// Fungsi bukit: Menggambar bukit bergelombang memakai kurva bezier (Modul 2).
void bukit(float g, float yBase, float tinggi, float seg, color c) {
  fill(c);
  noStroke();
  int i0 = floor(g / seg);
  float x0 = i0 * seg - g;
  int n = ceil(width / seg) + 2;

  beginShape();
  vertex(x0, height);
  vertex(x0, yBase);
  // Perulangan for: tambahkan satu gelombang bezier per segmen.
  for (int i = 0; i < n; i++) {
    int m = (i0 + i) % 3;
    float t = tinggi * (m == 0 ? 1.0 : (m == 1 ? 0.65 : 0.85));
    float x = x0 + i * seg;
    bezierVertex(x + seg * 0.3, yBase - t, x + seg * 0.7, yBase - t, x + seg, yBase);
  }
  vertex(x0 + n * seg, height);
  endShape(CLOSE);
}

// Fungsi kristal: Menggambar kristal dari quad dan triangle.
void kristal(float x, float y, float s, color c) {
  noStroke();
  fill(c);
  quad(x, y - s * 1.6, x + s * 0.8, y, x, y + s * 1.2, x - s * 0.8, y);
  fill(255, 255, 255, 90);
  triangle(x, y - s * 1.6, x + s * 0.8, y, x, y);
}

// Fungsi jalankanGame: Satu frame gameplay: update (jika PLAY), gambar latar, dunia 3D, vinyet goa, cuaca, efek petir, dan HUD.
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

  if (kilat > 0.02) {
    noStroke();
    fill(255, 255, 255, 150 * kilat);
    rect(0, 0, width, height);
  }

  gambarHUD();
}

// Fungsi gambarLatarGame: Memilih fungsi latar sesuai nomor level.
void gambarLatarGame() {
  // switch: pilih latar sesuai level.
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
    latarLevel5(); // Arahkan defaultnya ke level 5
    break;
  }
}

// Fungsi gambarDunia: Menggambar dunia 3D: platform (box) dengan cahaya, lalu duri, koin, bendera, portal, bola, dan partikel tanpa cahaya.
void gambarDunia() {
  // Nyalakan depth test untuk objek 3D.
  hint(ENABLE_DEPTH_TEST);
  pushMatrix();
  // Geser dunia ke kiri sebesar posisi kamera (kamera mengikuti pemain).
  translate(-cameraX, 0);

  // Pasang lampu untuk objek 3D.
  aturCahaya();

  // Perulangan for-each: gambar semua platform.
  for (Platform p : platforms) {
    p.display();
  }
  // Matikan lampu: objek berikutnya berwarna datar.
  noLights();

  // Perulangan for-each: gambar semua duri.
  for (Spike s : spikes) {
    s.display();
  }

  pushMatrix();
  // Geser ke depan platform (sumbu z) agar objek 2D tidak tertutup box.
  translate(0, 0, 40);
  // Perulangan for-each: gambar semua koin.
  for (Coin c : coins) {
    c.display();
  }
  gambarCheckpoint();
  gambarPortal();
  player.display();
  // Perulangan for-each: gambar semua partikel.
  for (Particle p : particles) {
    p.display();
  }
  popMatrix();

  popMatrix();
  // Matikan depth test agar gambar 2D (latar, HUD) tidak saling menutupi.
  hint(DISABLE_DEPTH_TEST);
}

// Fungsi aturCahaya: Mengatur pencahayaan 3D (Modul 6): goa memakai pointLight di bola, level lain memakai directionalLight.
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

// Fungsi buatVinyet: Membuat gambar gradasi gelap di tepi (alpha) untuk efek senter di goa.
PImage buatVinyet(int w, int h) {
  PImage im = createImage(w, h, ARGB);
  im.loadPixels();
  // Perulangan for: setiap baris piksel.
  for (int y = 0; y < h; y++) {
    // Perulangan for: setiap kolom piksel; alpha makin gelap menjauhi pusat.
    for (int x = 0; x < w; x++) {
      float d = dist(x, y, w / 2.0, h / 2.0) / (w / 2.0);
      float a = constrain(map(d, 0.18, 0.9, 0, 235), 0, 235);
      im.pixels[y * w + x] = color(4, 6, 16, a);
    }
  }
  im.updatePixels();
  return im;
}

// Fungsi gambarVinyet: Menempel gambar vinyet di posisi bola pada layar.
void gambarVinyet() {
  float sx = player.x - cameraX;
  float sy = player.y;
  imageMode(CENTER);
  tint(255, 238 + sin(waktuAnimasi * 7) * 14);
  image(vinyet, sx, sy, 1800, 1170);
  noTint();
  imageMode(CORNER);
}

// Fungsi hati: Menggambar ikon hati (nyawa) memakai bezierVertex.
void hati(float x, float y, float s) {
  beginShape();
  vertex(x, y + s * 0.6);
  bezierVertex(x - s, y - s * 0.1, x - s * 0.5, y - s * 0.9, x, y - s * 0.3);
  bezierVertex(x + s * 0.5, y - s * 0.9, x + s, y - s * 0.1, x, y + s * 0.6);
  endShape(CLOSE);
}

// Fungsi gambarHUD: Menggambar HUD: nama level, hati nyawa, skor, koin, dan petunjuk tombol.
void gambarHUD() {
  noStroke();
  fill(255, 255, 235, 235);
  rect(15, 15, 340, 72, 12);

  fill(35, 85, 45);
  textAlign(LEFT, CENTER);
  textSize(14);
  text("LEVEL " + level + " - " + lv.nama, 30, 33);

  // Perulangan for: gambar 3 hati; terisi jika nyawa masih ada.
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

// Fungsi gambarCheckpoint: Menggambar tiang dan bendera checkpoint yang berkibar.
void gambarCheckpoint() {
  float x = lv.cpX;
  float y = lv.cpY;

  pushMatrix();
  translate(x, y - 30, 0);
  noStroke();
  fill(115, 85, 45);
  box(6, 60, 6);
  popMatrix();

  float y0 = y - 58;
  float k = sin(waktuAnimasi * 4) * 5;
  fill(checkpointAktif ? color(255, 220, 40) : color(230, 70, 55));
  beginShape();
  vertex(x, y0);
  bezierVertex(x + 12, y0 + k, x + 24, y0 - k, x + 38, y0 + 10);
  bezierVertex(x + 24, y0 + 14 - k, x + 12, y0 + 14 + k, x, y0 + 26);
  endShape(CLOSE);
}

// Fungsi gambarPortal: Menggambar portal EXIT dari cincin yang berputar (rotateY).
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
  // Perulangan for: gambar 4 cincin dengan rotasi berbeda.
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

// ----- CLASS Tombol: tombol GUI (posisi, label, warna) dengan deteksi hover mouse (Modul 4). -----
class Tombol {
  float x, y, w, h;
  String label;
  color warna;

  // Konstruktor Tombol: simpan posisi, ukuran, label, dan warna.
  Tombol(float x, float y, float w, float h, String label, color warna) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.warna = warna;
  }

  // Mengembalikan true jika kursor mouse berada di dalam area tombol.
  boolean hover() {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  // Menggambar tombol; saat hover warnanya menyala dan ada efek glow.
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

// ----- CLASS GeserVolume: slider untuk mengatur volume suara dengan mouse. -----
class GeserVolume {
  float x, y, w;
  boolean drag = false;

  // Konstruktor slider: posisi dan panjang track.
  GeserVolume(float x, float y, float w) {
    this.x = x;
    this.y = y;
    this.w = w;
  }

  // True jika mouse berada di area slider.
  boolean kena() {
    return mouseX >= x - 12 && mouseX <= x + w + 12 && mouseY >= y - 14 && mouseY <= y + 14;
  }

  // Mulai menggeser slider saat mouse ditekan di atasnya.
  void tekan() {
    if (kena()) {
      drag = true;
      ubah();
    }
  }

  // Mengubah nilai volume sesuai posisi mouse (0 sampai 1) lalu menerapkannya.
  void ubah() {
    volume = constrain((mouseX - x) / w, 0, 1);
    terapkanVolume();
  }

  // Menggambar teks volume, track, bagian terisi, dan tombol geser.
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

// Objek GUI: tombol dan slider volume.
Tombol btnMulai, btnPilih, btnPetunjuk, btnKembali;
Tombol btnLanjut, btnAturan, btnMenuPause;
// Objek GUI: tombol dan slider volume.
Tombol btnMulaiAturan, btnAksi1, btnAksi2;
GeserVolume sliderMenu, sliderPause;

// Fungsi buatTombol: Membuat semua objek Tombol dan slider dengan posisi awal. (Posisinya akan diupdate dinamis oleh updatePosisiUI)
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

// Fungsi mulaiTransformPopup: Menyiapkan popup: layar digelapkan dan popup di-scale membesar (animasi) memakai transformasi.
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

// Fungsi panel: Menggambar panel popup (bayangan, kotak putih, header berwarna, judul).
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

// Fungsi gambarBanner: Menggambar banner mini level dari bentuk dasar (tanpa gambar).
void gambarBanner(int idx, float x, float y, float w, float h) {
  Level L = infoLevel(constrain(idx, 1, JUMLAH_LEVEL));
  noStroke();
  // Perulangan for: gradasi langit per 4 piksel.
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
  // Perulangan for: gambar 3 duri kecil.
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

// Fungsi gambarPopupAturan: Popup aturan level: misi, daftar aturan, dan tombol mulai.
void gambarPopupAturan() {
  mulaiTransformPopup();
  float w = 660, h = 450, x = (width - w) / 2, y = (height - h) / 2;
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
  // Perulangan for: tampilkan setiap baris aturan level.
  for (int i = 0; i < lv.aturan.length; i++) {
    text("-  " + lv.aturan[i], x + 28, y + 242 + i * 28, w - 56, 28);
  }

  fill(110, 130, 110);
  textAlign(CENTER, CENTER);
  textSize(12);
  text("A / D gerak  |  SPASI lompat  |  P pause  |  M suara  |  H buka aturan", x + w / 2, y + h - 80);

  btnMulaiAturan.label = (stateSebelumRules == PAUSE) ? "KEMBALI" : "MULAI";
  btnMulaiAturan.display();
  popMatrix();
}

// Fungsi darker: Mengembalikan versi lebih gelap dari sebuah warna.
color darker(color c) {
  return color(red(c) * 0.6, green(c) * 0.6, blue(c) * 0.6);
}

// Fungsi gambarOverlayPause: Popup pause: tombol lanjut, aturan, menu utama, dan slider volume.
void gambarOverlayPause() {
  mulaiTransformPopup();
  panel(width / 2 - 170, 190, 340, 340, "PAUSE", ungu);
  btnLanjut.display();
  btnAturan.display();
  btnMenuPause.display();
  sliderPause.display();
  popMatrix();
}

// Fungsi gambarPopupLevelSelesai: Popup level selesai: statistik level dan tombol level berikutnya.
void gambarPopupLevelSelesai() {
  mulaiTransformPopup();
  panel(width / 2 - 200, 130, 400, 400, "LEVEL " + level + " SELESAI!", color(45, 160, 60));
  fill(35, 85, 45);
  textAlign(CENTER, CENTER);
  textSize(18);
  text(lv.nama, width / 2, 215);
  textSize(17);
  text("Koin level ini : " + (jumlahKoin - koinAwalLevel), width / 2, 255);
  text("Bonus selesai : +500", width / 2, 285);
  text("Nyawa tersisa : " + nyawa, width / 2, 315);
  fill(180, 130, 20);
  textSize(22);
  text("SKOR  " + skor, width / 2, 355);
  btnAksi1.label = "LEVEL BERIKUTNYA";
  btnAksi1.display();
  btnAksi2.display();
  popMatrix();
}

// Fungsi gambarPopupMenang: Popup tamat game: skor akhir dan tombol main lagi.
void gambarPopupMenang() {
  mulaiTransformPopup();
  panel(width / 2 - 220, 120, 440, 420, "SELAMAT! BOUNCE TAMAT", color(230, 160, 20));
  fill(35, 85, 45);
  textAlign(CENTER, CENTER);
  textSize(17);
  text("Kamu menyelesaikan semua " + JUMLAH_LEVEL + " level:", width / 2, 210);
  text("Padang Hujan, Salju, Istana Es,", width / 2, 238);
  text("Goa Kristal, dan Kawah Lava.", width / 2, 262);
  text("Total koin : " + jumlahKoin, width / 2, 305);
  fill(180, 130, 20);
  textSize(24);
  text("SKOR AKHIR  " + skor, width / 2, 345);
  btnAksi1.label = "MAIN LAGI";
  btnAksi1.display();
  btnAksi2.display();
  popMatrix();
}

// Fungsi gambarPopupKalah: Popup game over: skor dan tombol coba lagi.
void gambarPopupKalah() {
  mulaiTransformPopup();
  panel(width / 2 - 200, 150, 400, 360, "GAME OVER", color(215, 55, 45));
  fill(35, 85, 45);
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Nyawa habis di level " + level + " - " + lv.nama, width / 2, 235);
  textSize(21);
  text("Skor : " + skor, width / 2, 285);
  btnAksi1.label = "COBA LAGI";
  btnAksi1.display();
  btnAksi2.display();
  popMatrix();
}

// Fungsi latarMenu: Latar layar menu memakai gambar background yang bergulir.
void latarMenu() {
  gambarBg(0, waktuAnimasi * 25, color(100, 180, 255), color(215, 240, 255));
}

// Fungsi bolaHias: Menggambar bola merah dari ellipse (dipakai menu, banner, loading).
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

// Fungsi gambarMenu: Layar menu utama: bola memantul, judul, dan tombol.
void gambarMenu() {
  latarMenu();

  // Bola hias berjalan melintas layar, memantul dengan abs(sin).
  float bx = wrap(waktuAnimasi * 70, width + 100) - 50;
  float by = 590 - abs(sin(waktuAnimasi * 3)) * 140;
  bolaHias(bx, by, 22);

  float ly = 190 + sin(waktuAnimasi * 2) * 5;
  textAlign(CENTER, CENTER);
  textSize(76);
  fill(20, 70, 30);
  text("BOUNCE", width / 2 + 4, ly + 5);
  fill(60, 185, 70);
  text("BOUNCE", width / 2, ly);

  textAlign(CENTER, CENTER);
  fill(35, 110, 55);
  textSize(18);
  text("PETUALANGAN 5 DUNIA", width / 2, 312);

  btnMulai.display();
  btnPilih.display();
  btnPetunjuk.display();

  fill(40, 100, 55);
  textSize(12);
  text("FINAL PROJECT - COMPUTER GRAPHICS  |  PROCESSING JAVA MODE", width / 2, 560);
  sliderMenu.display();
}

// Fungsi gambarPetunjuk: Layar petunjuk: tabel kontrol dan penjelasan bahaya.
void gambarPetunjuk() {
  latarMenu();

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(36);
  text("CARA BERMAIN", width / 2, 50);

  noStroke();
  fill(255, 255, 245, 235);
  float boxX = (width - 740) / 2; // Menghitung posisi kotak agar selalu di tengah
  rect(boxX, 85, 740, 250, 18);

  fill(35, 105, 50);
  textSize(20);
  text("KONTROL", width / 2, 110);

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
  // Perulangan for: tampilkan setiap baris tabel kontrol.
  for (int i = 0; i < kontrol.length; i++) {
    text(kontrol[i][0], boxX + 40, 148 + i * 30);
    text(kontrol[i][1], boxX + 340, 148 + i * 30);
  }

  noStroke();
  fill(255, 255, 245, 235);
  rect(boxX, 350, 740, 220, 18);

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(20);
  text("DUNIA & BAHAYA", width / 2, 375);

  fill(35, 75, 45);
  textSize(15);
  text("Level 1 Padang Hujan  -  Level 2 Gunung Salju (licin)", width / 2, 410);
  text("Level 3 Istana Es (sangat licin, platform bergerak)  -  Level 4 Goa Kristal (gelap)", width / 2, 438);
  text("Level 5 Kawah Lava (Duri sepanjang jalan). Jatuh/Kena Duri = kurang nyawa.", width / 2, 476);
  text("Koin +100, checkpoint +250, selesai level +500. Capai portal hijau di ujung level.", width / 2, 504);
  text("Setiap level punya loading dan popup aturan sendiri.", width / 2, 532);

  btnKembali.display();
}

// Fungsi gambarPilihLevel: Layar pilih level: kartu level yang bisa diklik.
void gambarPilihLevel() {
  latarMenu();

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(36);
  text("PILIH LEVEL", width / 2, 70);

  // Mengatur matriks agar semua kartu otomatis berada tepat di tengah layar penuh
  pushMatrix();
  float totalLebar = (JUMLAH_LEVEL * 205 - 15) * 0.85; // Lebar total semua kartu beserta jaraknya
  float startX = (width - totalLebar) / 2;             // Menghitung titik awal perataan tengah

  translate(startX, 0);
  scale(0.85); // Dikecilkan sedikit agar ke-5 kartu dapat termuat rapi

  // Perulangan for: gambar kartu level 1 sampai 5.
  for (int i = 1; i <= JUMLAH_LEVEL; i++) {
    float x = (i - 1) * 205;
    float y = 130;

    // Logika perhitungan batas kursor (hover hitbox) dengan mempertimbangkan perataan tengah
    boolean hv = mouseX >= (x * 0.85 + startX) && mouseX <= ((x + 190) * 0.85 + startX) && mouseY >= (y * 0.85) && mouseY <= ((y + 340) * 0.85);

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

    // Penanganan saat kartu level diklik
    if (hv && mousePressed && gameState == PILIH) {
        klik();
        mulaiGameBaru(i);
        gameState = LOADING;
    }
  }
  popMatrix();

  btnKembali.display();
}

// Fungsi kartuHover sudah dipindahkan ke fungsi gambarPilihLevel untuk memfasilitasi skalabilitas rasio layar
boolean kartuHover(int i) {
  return false;
}

// Fungsi gambarLoading: Layar loading tiap level: progress bar, membangun level dan memuat audio bertahap, lalu membuka popup aturan.
void gambarLoading() {
  loadTimer++;
  float p = constrain(loadTimer / (float) DURASI_LOADING, 0, 1);

  String pesan = "Menyiapkan dunia...";
  // Tahap loading 1: bangun level (sekali saja).
  if (p >= 0.35 && !levelDibuat) {
    buatLevel();
    levelDibuat = true;
  }
  // Tahap loading 2: muat dan putar musik level.
  if (p >= 0.7 && !audioSiap) {
    mainkanBgm(lv.indexBgm);
    audioSiap = true;
  }
  if (p >= 0.35) pesan = "Membangun level...";
  if (p >= 0.7) pesan = "Memuat audio...";

  gambarBg(level, waktuAnimasi * 30, lv.langitA, lv.langitB);
  noStroke();

  textAlign(CENTER, CENTER);
  fill(255);
  textSize(20);
  text("LEVEL " + level, width / 2, 60);
  textSize(46);
  text(lv.nama, width / 2, 105);

  gambarBanner(level, width / 2 - 220, 150, 440, 250);

  float bx = width / 2 - 250, by = 470, bw = 500, bh = 22;
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
  text(pesan + "  " + floor(p * 100) + "%", width / 2, by + 48);
  textSize(13);
  fill(255, 255, 255, 220);
  text(lv.tip, width / 2, by + 80);

  // Loading selesai: buka popup aturan.
  if (loadTimer >= DURASI_LOADING && levelDibuat) {
    stateSebelumRules = PLAY;
    ubahState(RULES);
  }
}

// Objek suara: efek (sfx) dan musik latar (bgm).
SoundFile sfxLompat, sfxKoin, sfxKena, sfxCheckpoint, sfxMenang, sfxKlik;
SoundFile[] bgm = new SoundFile[JUMLAH_LEVEL + 1];
// Nama file musik latar di data/audio (Tambahin 1 bgm_level4 di ujung biar gak error di level 5)
String[] namaBgm = {
  "bgm_menu.wav", "bgm_level1.wav", "bgm_level2.wav", "bgm_level3.wav", "bgm_level4.wav", "bgm_level4.wav"
};

// Pengaturan volume, mute, dan musik yang sedang aktif.
float volume = 0.6;
boolean senyap = false;
int bgmAktif = -1;

// Fungsi muatSuara: Memuat file suara dari data/audio; mengembalikan null jika file tidak ada.
SoundFile muatSuara(String nama) {
  // Penanganan error: jika file/audio gagal dimuat, program tidak crash.
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

// Fungsi muatGambar: Memuat gambar dari data/image; mengembalikan null jika file tidak ada.
PImage muatGambar(String nama) {
  File f = new File(dataPath("image/" + nama));
  if (!f.exists()) {
    println("Gambar tidak ditemukan: " + nama);
    return null;
  }
  return loadImage("image/" + nama);
}

// Fungsi muatSemuaSfx: Memuat semua efek suara (lompat, koin, kena, checkpoint, menang, klik).
void muatSemuaSfx() {
  sfxLompat = muatSuara("lompat.wav");
  sfxKoin = muatSuara("koin.wav");
  sfxKena = muatSuara("kena.wav");
  sfxCheckpoint = muatSuara("checkpoint.wav");
  sfxMenang = muatSuara("menang.wav");
  sfxKlik = muatSuara("klik.wav");
}

// Fungsi mainkanSfx: Memutar satu efek suara dengan volume saat ini (kecuali mute).
void mainkanSfx(SoundFile s) {
  if (s == null || senyap) return;
  s.amp(volume);
  s.play();
}

// Fungsi klik: Memutar suara klik tombol.
void klik() {
  mainkanSfx(sfxKlik);
}

// Fungsi mainkanBgm: Memutar musik latar nomor i secara berulang (loop); menghentikan musik sebelumnya.
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

// Fungsi hentikanBgm: Menghentikan musik latar yang sedang aktif.
void hentikanBgm() {
  if (bgmAktif >= 0 && bgm[bgmAktif] != null) {
    bgm[bgmAktif].stop();
  }
  bgmAktif = -1;
}

// Fungsi terapkanVolume: Menerapkan volume/mute ke musik latar yang sedang berjalan.
void terapkanVolume() {
  if (bgmAktif >= 0 && bgm[bgmAktif] != null) {
    bgm[bgmAktif].amp(senyap ? 0 : volume * 0.5);
  }
}

// Fungsi gambarBg: Menggambar gambar background berulang ke samping dengan paralaks; tile genap-ganjil dicerminkan agar tersambung mulus.
void gambarBg(int idx, float geser, color a, color b) {
  // Jika gambar tidak ada, pakai gradien.
  PImage im = imgBg[idx];
  if (im == null) {
    gradien(a, b);
    return;
  }
  float w = im.width * (height / (float) im.height);
  int n = floor(geser / w);
  float x = -(geser - n * w);
  int i = 0;
  // Perulangan while: tempel tile gambar sampai menutupi lebar layar.
  while (x < width) {
    // Tile ganjil dicerminkan (scale -1) agar sambungan gambar mulus.
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
