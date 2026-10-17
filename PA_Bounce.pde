
ArrayList<Platform> platforms = new ArrayList<Platform>();
ArrayList<Spike> spikes = new ArrayList<Spike>();
ArrayList<Coin> coins = new ArrayList<Coin>();
ArrayList<Particle> particles = new ArrayList<Particle>();

Player player;

final int MENU = 0;
final int HELP = 1;
final int PLAY = 2;
final int PAUSE = 3;
final int WIN = 4;
final int LOSE = 5;

int gameState = MENU;
int level = 1;
int nyawa = 3;
int skor = 0;
int jumlahKoin = 0;

float worldWidth = 2800;
float cameraX = 0;
float checkpointX = 80;
float waktuAnimasi = 0;

boolean tombolKiri = false;
boolean tombolKanan = false;
boolean tombolLompat = false;
boolean permintaanLompat = false;
boolean checkpointAktif = false;

color merah = color(235, 55, 45);
color cyan = color(70, 190, 65);
color ungu = color(60, 145, 235);
color gelap = color(35, 85, 45);

void setup() {
  size(1000, 650, P3D);
  smooth(4);
  frameRate(60);
  sphereDetail(20);

  buatLevel();
}

void draw() {
  waktuAnimasi += 0.04;

  if (gameState == MENU) {
    gambarMenu();
  } else if (gameState == HELP) {
    gambarPetunjuk();
  } else if (gameState == PLAY || gameState == PAUSE) {
    jalankanGame();

    if (gameState == PAUSE) {
      gambarOverlayPause();
    }
  } else if (gameState == WIN) {
    gambarLatarGame();
    gambarOverlayMenang();
  } else if (gameState == LOSE) {
    gambarLatarGame();
    gambarOverlayKalah();
  }
}

// ==================== LATAR ====================

void gambarLatar() {
  background(115, 205, 255);
  noStroke();

  fill(255, 225, 75);
  ellipse(width - 110, 95, 76, 76);

  fill(135, 215, 115);
  ellipse(100, 510, 380, 250);
  ellipse(390, 510, 430, 280);
  ellipse(760, 515, 430, 270);
  ellipse(1050, 510, 360, 250);

  fill(75, 185, 75);
  rect(0, 545, width, height - 545);

  fill(55, 160, 60);
  ellipse(180, 565, 420, 100);
  ellipse(650, 570, 520, 110);
  ellipse(1000, 565, 380, 100);

  gambarAwanMenu();
}

void gambarAwanMenu() {
  noStroke();

  for (int i = 0; i < 5; i++) {
    float x = (i * 235 + 70 - waktuAnimasi * 8) % (width + 180);

    if (x < -80) {
      x += width + 180;
    }

    float y = 65 + (i % 3) * 45;

    fill(255, 255, 255, 210);
    ellipse(x, y, 70, 28);
    ellipse(x - 20, y + 2, 35, 23);
    ellipse(x + 18, y - 7, 38, 30);
  }
}

void gambarLatarGame() {
  background(120, 210, 255);
  noStroke();

  fill(255, 225, 75);
  ellipse(850 - cameraX * 0.04, 95, 72, 72);

  for (int i = 0; i < 6; i++) {
    float x = i * 230 - (cameraX * 0.18) % 230;
    float y = 95 + (i % 2) * 55;

    fill(255, 255, 255, 220);
    ellipse(x, y, 75, 28);
    ellipse(x - 18, y + 1, 38, 25);
    ellipse(x + 18, y - 7, 40, 32);
  }

  fill(150, 220, 125);

  for (int i = 0; i < 8; i++) {
    float x = i * 250 - (cameraX * 0.12) % 250;
    ellipse(x, 500, 360, 230);
  }

  fill(105, 200, 85);

  for (int i = 0; i < 8; i++) {
    float x = i * 250 - (cameraX * 0.22) % 250;
    ellipse(x + 90, 555, 370, 190);
  }

  fill(75, 185, 65);
  rect(0, 585, width, 65);

  fill(55, 160, 55);

  for (int i = 0; i < width; i += 34) {
    triangle(i, 590, i + 8, 575, i + 15, 590);
  }
}

// ==================== MENU ====================

void gambarMenu() {
  gambarLatar();

  noStroke();
  fill(255, 255, 255, 110);
  ellipse(width / 2, 190, 230, 230);

  fill(195, 35, 35);
  ellipse(width / 2, 180 + sin(waktuAnimasi * 2) * 5, 95, 95);

  fill(235, 55, 45);
  ellipse(width / 2 - 2, 178 + sin(waktuAnimasi * 2) * 5, 82, 82);

  fill(255, 150, 125, 190);
  ellipse(width / 2 - 15, 165 + sin(waktuAnimasi * 2) * 5, 12, 12);

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(60);
  text("BOUNCE", width / 2, 287);

  fill(35, 110, 55);
  textSize(19);
  text("PETUALANGAN DI PADANG RUMPUT", width / 2, 333);

  tombol(width / 2 - 115, 390, 230, 54,
    "MULAI BERMAIN", cyan);

  tombol(width / 2 - 115, 460, 230, 48,
    "PETUNJUK", ungu);

  fill(40, 100, 55);
  textSize(12);
  text("FINAL PROJECT - COMPUTER GRAPHICS", width / 2, 560);
  text("PROCESSING JAVA MODE", width / 2, 582);
}

void gambarPetunjuk() {
  gambarLatar();

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(36);
  text("CARA BERMAIN", width / 2, 75);

  noStroke();
  fill(255, 255, 245, 235);
  rect(170, 110, 660, 275, 18);

  fill(35, 105, 50);
  textSize(20);
  text("KONTROL PERMAINAN", width / 2, 140);

  textAlign(LEFT, CENTER);
  fill(35, 75, 45);
  textSize(16);

  text("A / D atau panah kiri / kanan", 210, 190);
  text("Bergerak ke kiri dan kanan", 500, 190);

  text("SPASI / W / panah atas", 210, 235);
  text("Melompat", 500, 235);

  text("P / ESC", 210, 280);
  text("Jeda atau lanjutkan permainan", 500, 280);

  text("MOUSE", 210, 325);
  text("Memilih tombol pada menu", 500, 325);

  noStroke();
  fill(255, 255, 245, 235);
  rect(170, 400, 660, 130, 18);

  textAlign(CENTER, CENTER);
  fill(35, 105, 50);
  textSize(20);
  text("TUJUAN PERMAINAN", width / 2, 423);

  fill(35, 75, 45);
  textSize(15);
  text("Kumpulkan koin dan hindari duri serta jurang.", width / 2, 455);
  text("Aktifkan checkpoint dan capai portal hijau.", width / 2, 485);
  text("Selesaikan kedua level untuk memenangkan game.", width / 2, 510);

  tombol(width / 2 - 110, 565, 220, 45, "KEMBALI", cyan);
}

// ==================== LEVEL ====================

void buatLevel() {
  platforms.clear();
  spikes.clear();
  coins.clear();
  particles.clear();

  cameraX = 0;
  checkpointX = 80;
  checkpointAktif = false;

  if (level == 1) {
    worldWidth = 2800;

    platforms.add(new Platform(0, 560, 420, 100));
    platforms.add(new Platform(510, 560, 280, 100));
    platforms.add(new Platform(880, 500, 180, 25));
    platforms.add(new Platform(1120, 440, 190, 25));
    platforms.add(new Platform(1370, 500, 240, 25));
    platforms.add(new Platform(1690, 560, 260, 100));
    platforms.add(new Platform(2010, 500, 180, 25));
    platforms.add(new Platform(2250, 440, 200, 25));
    platforms.add(new Platform(2510, 560, 290, 100));

    tambahDuri(250, 560, 5);
    tambahDuri(610, 560, 3);
    tambahDuri(1730, 560, 3);
    tambahDuri(2590, 560, 3);

    tambahKoin(170, 510);
    tambahKoin(335, 490);
    tambahKoin(580, 505);
    tambahKoin(720, 505);
    tambahKoin(930, 455);
    tambahKoin(1190, 395);
    tambahKoin(1450, 455);
    tambahKoin(1550, 455);
    tambahKoin(1770, 505);
    tambahKoin(1850, 505);
    tambahKoin(2070, 455);
    tambahKoin(2320, 395);
    tambahKoin(2640, 505);

  } else {
    worldWidth = 3400;

    platforms.add(new Platform(0, 560, 300, 100));
    platforms.add(new Platform(390, 500, 160, 25));
    platforms.add(new Platform(620, 430, 160, 25));
    platforms.add(new Platform(850, 500, 170, 25));
    platforms.add(new Platform(1100, 560, 240, 100));
    platforms.add(new Platform(1430, 480, 180, 25));
    platforms.add(new Platform(1680, 410, 170, 25));
    platforms.add(new Platform(1920, 480, 200, 25));
    platforms.add(new Platform(2200, 560, 220, 100));
    platforms.add(new Platform(2500, 490, 170, 25));
    platforms.add(new Platform(2740, 420, 180, 25));
    platforms.add(new Platform(2990, 500, 410, 100));

    tambahDuri(140, 560, 3);
    tambahDuri(1160, 560, 4);
    tambahDuri(2250, 560, 3);
    tambahDuri(3090, 500, 3);

    tambahKoin(200, 505);
    tambahKoin(430, 455);
    tambahKoin(670, 385);
    tambahKoin(900, 455);
    tambahKoin(1200, 505);
    tambahKoin(1480, 435);
    tambahKoin(1730, 365);
    tambahKoin(1980, 435);
    tambahKoin(2290, 505);
    tambahKoin(2550, 445);
    tambahKoin(2790, 375);
    tambahKoin(3180, 445);
  }

  player = new Player(100, 490);
}

void tambahDuri(float x, float y, int jumlah) {
  for (int i = 0; i < jumlah; i++) {
    spikes.add(new Spike(x + i * 24, y));
  }
}

void tambahKoin(float x, float y) {
  coins.add(new Coin(x, y));
}

// ==================== GAMEPLAY ====================

void jalankanGame() {
  if (gameState == PLAY) {
    player.update();

    periksaKoin();
    periksaDuri();
    periksaCheckpoint();
    periksaKemenangan();

    if (gameState == PLAY && player.y > height + 100) {
      kehilanganNyawa();
    }

    cameraX = constrain(player.x - width * 0.38,
      0, worldWidth - width);

    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();

      if (p.umur <= 0) {
        particles.remove(i);
      }
    }
  }

  gambarLatarGame();

  pushMatrix();
  translate(-cameraX, 0);

  for (Platform p : platforms) {
    p.display();
  }

  for (Spike s : spikes) {
    s.display();
  }

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
  gambarHUD();
}

void gambarHUD() {
  noStroke();
  fill(255, 255, 235, 235);
  rect(15, 15, 330, 72, 12);

  fill(35, 85, 45);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("LEVEL " + level, 32, 37);
  text("SKOR  " + skor, 32, 65);

  fill(215, 55, 45);
  text("NYAWA  " + nyawa, 190, 37);

  fill(180, 130, 20);
  text("KOIN  " + jumlahKoin, 190, 65);

  fill(255, 255, 245, 225);
  rect(width - 245, 15, 230, 34, 9);

  fill(35, 85, 45);
  textAlign(CENTER, CENTER);
  textSize(12);
  text("P / ESC : PAUSE", width - 130, 32);

  fill(255, 255, 245, 225);
  rect(width - 280, height - 58, 265, 43, 9);

  fill(35, 85, 45);
  textSize(12);
  text("A / D : GERAK   |   SPASI : LOMPAT",
    width - 147, height - 36);
}

void gambarCheckpoint() {
  float x = level == 1 ? 1690 : 2200;
  float y = level == 1 ? 500 : 500;

  pushMatrix();
  translate(x, y);

  stroke(115, 85, 45);
  strokeWeight(4);
  line(0, 0, 0, 60);

  noStroke();
  fill(checkpointAktif ? color(255, 220, 40) : color(230, 70, 55));
  triangle(0, 0, 35, 12, 0, 25);

  popMatrix();
}

void gambarPortal() {
  float x = worldWidth - 100;
  float y = 510;

  noFill();
  stroke(50, 200, 75, 65);
  strokeWeight(18);
  ellipse(x, y, 80, 80);

  stroke(40, 170, 65);
  strokeWeight(4);
  ellipse(x, y, 55, 65);

  noStroke();
  fill(100, 230, 95, 80);
  ellipse(x, y, 45, 55);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(12);
  text("EXIT", x, y + 1);
}

// ==================== KOIN DAN DURI ====================

void periksaKoin() {
  for (Coin c : coins) {
    if (!c.terambil &&
        dist(player.x, player.y, c.x, c.y) < 30) {
      c.terambil = true;
      skor += 100;
      jumlahKoin++;

      for (int i = 0; i < 8; i++) {
        particles.add(new Particle(c.x, c.y, color(255, 205, 65)));
      }
    }
  }
}

void periksaDuri() {
  for (Spike s : spikes) {
    if (bolaMenyentuhSegitiga(
      player.x, player.y, player.r * 0.9,
      s.x, s.y,
      s.x + 12, s.y - 27,
      s.x + 24, s.y
      )) {
      kehilanganNyawa();
      return;
    }
  }
}

boolean bolaMenyentuhSegitiga(
  float cx, float cy, float r,
  float x1, float y1,
  float x2, float y2,
  float x3, float y3
) {
  if (titikDalamSegitiga(cx, cy, x1, y1, x2, y2, x3, y3)) {
    return true;
  }

  if (jarakTitikKeGaris(cx, cy, x1, y1, x2, y2) <= r ||
      jarakTitikKeGaris(cx, cy, x2, y2, x3, y3) <= r ||
      jarakTitikKeGaris(cx, cy, x3, y3, x1, y1) <= r) {
    return true;
  }

  return false;
}

boolean titikDalamSegitiga(
  float px, float py,
  float x1, float y1,
  float x2, float y2,
  float x3, float y3
) {
  float d1 = (px - x2) * (y1 - y2)
    - (x1 - x2) * (py - y2);

  float d2 = (px - x3) * (y2 - y3)
    - (x2 - x3) * (py - y3);

  float d3 = (px - x1) * (y3 - y1)
    - (x3 - x1) * (py - y1);

  boolean negatif = d1 < 0 || d2 < 0 || d3 < 0;
  boolean positif = d1 > 0 || d2 > 0 || d3 > 0;

  return !(negatif && positif);
}

float jarakTitikKeGaris(
  float px, float py,
  float x1, float y1,
  float x2, float y2
) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float panjangKuadrat = dx * dx + dy * dy;

  if (panjangKuadrat == 0) {
    return dist(px, py, x1, y1);
  }

  float t = ((px - x1) * dx + (py - y1) * dy)
    / panjangKuadrat;

  t = constrain(t, 0, 1);

  float titikX = x1 + t * dx;
  float titikY = y1 + t * dy;

  return dist(px, py, titikX, titikY);
}

// ==================== CHECKPOINT DAN LEVEL ====================

void periksaCheckpoint() {
  float posisiCheckpoint = level == 1 ? 1690 : 2200;

  if (player.x > posisiCheckpoint && !checkpointAktif) {
    checkpointAktif = true;
    checkpointX = posisiCheckpoint;
    skor += 250;

    for (int i = 0; i < 18; i++) {
      particles.add(new Particle(
        posisiCheckpoint, 500, color(255, 220, 40)
      ));
    }
  }
}

void periksaKemenangan() {
  if (player.x >= worldWidth - 120) {
    if (level == 1) {
      level = 2;
      buatLevel();
      gameState = PLAY;
    } else {
      gameState = WIN;
      resetInput();
    }
  }
}

void kehilanganNyawa() {
  nyawa--;
  resetInput();

  if (nyawa <= 0) {
    gameState = LOSE;
  } else {
    player = new Player(checkpointX + 30, 470);
    cameraX = max(0, checkpointX - 300);
  }
}

// ==================== TOMBOL GUI ====================

void tombol(float x, float y, float w, float h,
  String tulisan, color warna) {

  boolean hover = mouseX >= x && mouseX <= x + w &&
    mouseY >= y && mouseY <= y + h;

  noStroke();

  if (hover) {
    fill(red(warna), green(warna), blue(warna), 65);
    rect(x - 4, y - 4, w + 8, h + 8, 13);
    fill(warna);
  } else {
    fill(255, 255, 235);
  }

  rect(x, y, w, h, 10);

  noFill();
  stroke(warna);
  strokeWeight(hover ? 2.5 : 1.5);
  rect(x, y, w, h, 10);

  noStroke();
  fill(35, 85, 45);
  textAlign(CENTER, CENTER);
  textSize(15);
  text(tulisan, x + w / 2, y + h / 2);
}

// ==================== PAUSE DAN HASIL ====================

void gambarOverlayPause() {
  noStroke();
  fill(255, 255, 255, 190);
  rect(0, 0, width, height);

  fill(35, 85, 45);
  textAlign(CENTER, CENTER);
  textSize(44);
  text("PAUSED", width / 2, 245);

  tombol(width / 2 - 115, 315, 230, 52, "LANJUTKAN", cyan);
  tombol(width / 2 - 115, 385, 230, 48, "MENU UTAMA", ungu);
}

void gambarOverlayMenang() {
  noStroke();
  fill(255, 255, 255, 190);
  rect(0, 0, width, height);

  fill(45, 145, 55);
  textAlign(CENTER, CENTER);
  textSize(45);
  text("LEVEL SELESAI!", width / 2, 240);

  fill(35, 85, 45);
  textSize(21);
  text("Skor akhir: " + skor, width / 2, 300);
  text("Koin terkumpul: " + jumlahKoin, width / 2, 335);

  tombol(width / 2 - 115, 395, 230, 52, "MAIN LAGI", cyan);
  tombol(width / 2 - 115, 465, 230, 48, "MENU UTAMA", ungu);
}

void gambarOverlayKalah() {
  noStroke();
  fill(255, 255, 255, 190);
  rect(0, 0, width, height);

  fill(215, 55, 45);
  textAlign(CENTER, CENTER);
  textSize(43);
  text("GAME OVER", width / 2, 240);

  fill(35, 85, 45);
  textSize(20);
  text("Skor akhir: " + skor, width / 2, 300);

  tombol(width / 2 - 115, 365, 230, 52, "COBA LAGI", cyan);
  tombol(width / 2 - 115, 435, 230, 48, "MENU UTAMA", ungu);
}

// ==================== INPUT ====================

void mousePressed() {
  if (gameState == MENU) {
    if (mouseX >= width / 2 - 115 &&
        mouseX <= width / 2 + 115 &&
        mouseY >= 390 && mouseY <= 444) {
      mulaiGame();
    } else if (mouseX >= width / 2 - 115 &&
               mouseX <= width / 2 + 115 &&
               mouseY >= 460 && mouseY <= 508) {
      gameState = HELP;
    }

  } else if (gameState == HELP) {
    if (mouseX >= width / 2 - 110 &&
        mouseX <= width / 2 + 110 &&
        mouseY >= 565 && mouseY <= 610) {
      gameState = MENU;
    }

  } else if (gameState == PAUSE) {
    if (mouseX >= width / 2 - 115 &&
        mouseX <= width / 2 + 115 &&
        mouseY >= 315 && mouseY <= 367) {
      gameState = PLAY;
      resetInput();
    } else if (mouseX >= width / 2 - 115 &&
               mouseX <= width / 2 + 115 &&
               mouseY >= 385 && mouseY <= 433) {
      gameState = MENU;
      resetInput();
    }

  } else if (gameState == WIN || gameState == LOSE) {
    float yMain = gameState == WIN ? 395 : 365;
    float yMenu = gameState == WIN ? 465 : 435;

    if (mouseX >= width / 2 - 115 &&
        mouseX <= width / 2 + 115 &&
        mouseY >= yMain && mouseY <= yMain + 52) {
      mulaiGame();
    } else if (mouseX >= width / 2 - 115 &&
               mouseX <= width / 2 + 115 &&
               mouseY >= yMenu && mouseY <= yMenu + 48) {
      gameState = MENU;
      resetInput();
    }
  }
}

void keyPressed() {
  if (key == ESC) {
    key = 0;

    if (gameState == PLAY) {
      gameState = PAUSE;
      resetInput();
    } else if (gameState == PAUSE) {
      gameState = PLAY;
      resetInput();
    }
    return;
  }

  if (key == 'a' || key == 'A' || keyCode == LEFT) {
    tombolKiri = true;
  }

  if (key == 'd' || key == 'D' || keyCode == RIGHT) {
    tombolKanan = true;
  }

  if (key == ' ' || key == 'w' || key == 'W' || keyCode == UP) {
    if (!tombolLompat) {
      tombolLompat = true;
      permintaanLompat = true;
    }
  }

  if (key == 'p' || key == 'P') {
    if (gameState == PLAY) {
      gameState = PAUSE;
      resetInput();
    } else if (gameState == PAUSE) {
      gameState = PLAY;
      resetInput();
    }
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A' || keyCode == LEFT) {
    tombolKiri = false;
  }

  if (key == 'd' || key == 'D' || keyCode == RIGHT) {
    tombolKanan = false;
  }

  if (key == ' ' || key == 'w' || key == 'W' || keyCode == UP) {
    tombolLompat = false;
  }
}

void resetInput() {
  tombolKiri = false;
  tombolKanan = false;
  tombolLompat = false;
  permintaanLompat = false;
}

void mulaiGame() {
  resetInput();

  level = 1;
  nyawa = 3;
  skor = 0;
  jumlahKoin = 0;

  buatLevel();
  gameState = PLAY;
}

// ==================== CLASS PLAYER ====================

class Player {
  float x, y;
  float vx = 0;
  float vy = 0;
  float r = 18;
  float kecepatan = 4.5;
  float gravitasi = 0.48;
  float kekuatanLompat = -10.5;

  boolean diTanah = false;

  Player(float xAwal, float yAwal) {
    x = xAwal;
    y = yAwal;
  }

  void update() {
    if (tombolKiri && !tombolKanan) {
      vx = -kecepatan;
    } else if (tombolKanan && !tombolKiri) {
      vx = kecepatan;
    } else {
      vx = 0;
    }

    if (permintaanLompat) {
      if (diTanah) {
        lompat();
      }
      permintaanLompat = false;
    }

    x += vx;
    x = constrain(x, r, worldWidth - r);

    float yLama = y;

    vy += gravitasi;
    vy = min(vy, 12);
    y += vy;

    diTanah = false;

    for (Platform p : platforms) {
      boolean masukHorizontal =
        x + r > p.x && x - r < p.x + p.w;

      if (masukHorizontal &&
          yLama + r <= p.y &&
          y + r >= p.y &&
          vy >= 0) {
        y = p.y - r;
        vy = 0;
        diTanah = true;
      }
    }
  }

  void lompat() {
    if (diTanah && gameState == PLAY) {
      vy = kekuatanLompat;
      diTanah = false;

      for (int i = 0; i < 5; i++) {
        particles.add(new Particle(x, y + r, cyan));
      }
    }
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(vx * 0.035);

    noStroke();

    fill(35, 120, 45, 35);
    ellipse(0, r + 8, r * 2.1, 8);

    fill(195, 35, 35);
    ellipse(0, 0, r * 2, r * 2);

    fill(235, 55, 45);
    ellipse(-2, -2, r * 1.72, r * 1.72);

    fill(255, 150, 125, 190);
    ellipse(-6, -7, 7, 7);

    popMatrix();
  }
}

// ==================== CLASS PLATFORM ====================

class Platform {
  float x, y, w, h;

  Platform(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    noStroke();

    fill(145, 90, 45);
    rect(x, y, w, h, 3);

    fill(175, 115, 60);
    rect(x, y + 8, w, max(0, h - 8), 3);

    fill(55, 165, 55);
    rect(x, y, w, 9, 3);

    fill(100, 205, 70);
    rect(x, y, w, 3);

    stroke(125, 75, 40, 150);
    strokeWeight(2);

    for (float px = x + 18; px < x + w; px += 42) {
      line(px, y + 22, px + 8, min(y + h - 3, y + 30));
    }

    noStroke();
  }
}

// ==================== CLASS SPIKE ====================

class Spike {
  float x, y;

  Spike(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void display() {
    noStroke();

    fill(180, 45, 35);
    triangle(x, y, x + 12, y - 27, x + 24, y);

    fill(240, 70, 50);
    triangle(x + 4, y, x + 12, y - 23, x + 20, y);

    fill(255, 190, 150);
    triangle(x + 9, y - 7, x + 12, y - 23, x + 15, y - 7);
  }
}

// ==================== CLASS COIN ====================

class Coin {
  float x, y;
  boolean terambil = false;

  Coin(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void display() {
    if (terambil) {
      return;
    }

    float ukuran = 18 + sin(waktuAnimasi * 3 + x) * 2;

    noStroke();

    fill(255, 225, 80, 65);
    ellipse(x, y, ukuran * 2, ukuran * 2);

    fill(255, 205, 35);
    ellipse(x, y, ukuran, ukuran);

    fill(255, 245, 170);
    ellipse(x - 3, y - 3, ukuran * 0.35, ukuran * 0.35);
  }
}

// ==================== CLASS PARTICLE ====================

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

  void update() {
    x += vx;
    y += vy;
    vy += 0.12;
    umur--;
  }

  void display() {
    noStroke();
    fill(warna, map(umur, 0, 30, 0, 255));
    circle(x, y, map(umur, 0, 30, 1, 6));
  }
}
