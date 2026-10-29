// =====================================================
// LATAR (BACKGROUND) PROSEDURAL
// Semua latar digambar dari bentuk dasar (bezier, triangle, quad, ellipse) dengan paralaks,
// sama seperti latar Level 5, sehingga tidak butuh file gambar. Tiap level punya tema sendiri.
// =====================================================

// Bilangan acak semu yang konsisten (tidak berubah antar frame) berdasarkan angka masukan.
float acak(float n) {
  float v = sin(n * 12.9898) * 43758.5453;
  return v - floor(v);
}

// Barisan pohon cemara (siluet). Jika alpha(salju) > 0, puncak pohon diberi salju.
void barisPohon(float g, float yBase, float jarak, float tinggi, color c, color salju) {
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  noStroke();
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g + acak(id * 5.3) * jarak * 0.4;
    float h = tinggi * (0.7 + 0.5 * acak(id * 2.9));
    fill(c);
    rect(x - 2, yBase - h * 0.12, 4, h * 0.12 + 2);
    for (int k = 0; k < 3; k++) {
      float w = h * 0.34 * (1 - k * 0.25);
      float yb = yBase - h * 0.28 * k - h * 0.12;
      float yt = yb - h * 0.42;
      fill(c);
      triangle(x - w, yb, x + w, yb, x, yt);
      if (alpha(salju) > 0) {
        fill(salju);
        float y0 = yb - (yb - yt) * 0.45;
        triangle(x - w * 0.55, y0, x + w * 0.55, y0, x, yt);
      }
    }
  }
}

// Barisan gunung segitiga dengan puncak bersalju dan sisi bayangan (paralaks lewat g).
void gunung(float g, float yBase, float tinggi, float lebar, float jarak, color body, color salju) {
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  noStroke();
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g;
    float t = tinggi * (0.65 + 0.35 * acak(id * 3.1 + yBase));
    float w = lebar * (0.8 + 0.4 * acak(id * 1.7 + 4));
    fill(body);
    triangle(x - w / 2, yBase, x + w / 2, yBase, x, yBase - t);
    fill(0, 0, 0, 32);
    triangle(x, yBase - t, x + w / 2, yBase, x, yBase);
    float p = 0.32;
    float yy = yBase - t * (1 - p);
    float xl = x - w / 2 * p, xr = x + w / 2 * p;
    fill(salju);
    beginShape();
    vertex(x, yBase - t);
    vertex(xr, yy);
    vertex(x + w / 2 * p * 0.35, yy + 10);
    vertex(x, yy + 4);
    vertex(x - w / 2 * p * 0.4, yy + 12);
    vertex(xl, yy);
    endShape(CLOSE);
  }
  fill(body);
  rect(0, yBase - 1, VW, VH - yBase + 2);
}

// Pita aurora bergelombang untuk langit istana es.
void aurora(float g, float y0, float amp, color c, float fase) {
  noStroke();
  fill(c);
  beginShape(TRIANGLE_STRIP);
  for (float x = 0; x <= VW + 30; x += 30) {
    float yy = y0 + sin((x + g) * 0.006 + waktuAnimasi * 0.6 + fase) * amp
      + sin((x + g) * 0.013 + waktuAnimasi * 0.3) * amp * 0.4;
    vertex(x, yy);
    vertex(x, yy + 110 + sin(x * 0.02 + fase) * 20);
  }
  endShape();
}

// Bintang berkelip.
void bintang(float g) {
  noStroke();
  for (int i = 0; i < 70; i++) {
    float x = wrap(acak(i) * VW * 1.5 - g * 0.05, VW);
    float y = acak(i + 100) * 300;
    fill(255, 255, 255, 150 + 100 * sin(waktuAnimasi * 3 + i));
    ellipse(x, y, 2 + acak(i + 50) * 2, 2 + acak(i + 50) * 2);
  }
}

// Istana es: badan utama, gerigi, menara dengan atap runcing, jendela dan gerbang bercahaya.
void istanaEs(float g, float yBase, float jarak, float s, color c, color terang) {
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  noStroke();
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g + jarak * 0.5;
    fill(c);
    rect(x - 75 * s, yBase - 150 * s, 150 * s, 150 * s);
    for (int k = 0; k < 6; k++) {
      rect(x - 75 * s + k * 25 * s, yBase - 162 * s, 14 * s, 12 * s);
    }
    rect(x - 22 * s, yBase - 250 * s, 44 * s, 250 * s);
    triangle(x - 28 * s, yBase - 250 * s, x + 28 * s, yBase - 250 * s, x, yBase - 330 * s);
    for (int sd = -1; sd <= 1; sd += 2) {
      float tx = x + sd * 95 * s;
      rect(tx - 20 * s, yBase - 200 * s, 40 * s, 200 * s);
      triangle(tx - 26 * s, yBase - 200 * s, tx + 26 * s, yBase - 200 * s, tx, yBase - 265 * s);
      fill(terang);
      rect(tx - 5 * s, yBase - 160 * s, 10 * s, 22 * s, 5 * s);
      fill(c);
    }
    fill(terang);
    rect(x - 6 * s, yBase - 215 * s, 12 * s, 26 * s, 6 * s);
    rect(x - 50 * s, yBase - 110 * s, 12 * s, 24 * s, 6 * s);
    rect(x + 38 * s, yBase - 110 * s, 12 * s, 24 * s, 6 * s);
    fill(terang, 200);
    rect(x - 16 * s, yBase - 48 * s, 32 * s, 48 * s, 16 * s, 16 * s, 0, 0);
    fill(255, 255, 255, 45);
    rect(x - 22 * s, yBase - 250 * s, 10 * s, 250 * s);
  }
  fill(c);
  rect(0, yBase - 1, VW, VH - yBase + 2);
}

// Duri kristal es yang mencuat dari bawah (latar depan istana es).
void kristalEs(float g, float yBase, float jarak, float tinggi, color c) {
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  noStroke();
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g;
    float h = tinggi * (0.4 + 0.9 * acak(id * 4.1));
    float w = 26 + acak(id * 6.7) * 24;
    fill(c);
    triangle(x - w, yBase + 10, x + w, yBase + 10, x, yBase - h);
    fill(255, 255, 255, 90);
    triangle(x - w, yBase + 10, x, yBase + 10, x, yBase - h);
  }
}

// Stalaktit (dariAtas = true) atau stalagmit (false) sebagai siluet dinding goa.
void stalaktitLatar(float g, float jarak, float panjang, color c, boolean dariAtas) {
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  noStroke();
  fill(c);
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g;
    float len = panjang * (0.4 + 0.8 * acak(id * 2.3 + panjang));
    float w = jarak * (0.5 + 0.4 * acak(id * 7.7));
    if (dariAtas) triangle(x, -2, x + w, -2, x + w * 0.5, len);
    else triangle(x, VH + 2, x + w, VH + 2, x + w * 0.5, VH - len);
  }
  if (dariAtas) rect(0, -2, VW, 18);
  else rect(0, VH - 16, VW, 18);
}

// Gugusan kristal bercahaya yang berdenyut di dinding goa.
void kristalGoa(float g, float jarak, float s, int seed) {
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  color[] pal = {color(90, 210, 255), color(225, 100, 255), color(110, 150, 255), color(90, 255, 205)};
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g + acak(id * 3.3 + seed) * jarak * 0.6;
    float y = 150 + acak(id * 1.9 + seed) * 420;
    color c = pal[(id + seed) % 4];
    float k = 0.6 + 0.4 * sin(waktuAnimasi * 2 + id * 1.3);
    noStroke();
    fill(red(c), green(c), blue(c), 28 * k);
    ellipse(x, y, s * 9, s * 9);
    fill(red(c), green(c), blue(c), 45 * k);
    ellipse(x, y, s * 5, s * 5);
    kristal(x, y, s, color(red(c), green(c), blue(c), 190 + 50 * k));
    kristal(x + s * 1.2, y + s * 0.9, s * 0.6, color(red(c), green(c), blue(c), 170 + 50 * k));
    kristal(x - s * 1.1, y + s * 1.1, s * 0.5, color(red(c), green(c), blue(c), 160 + 50 * k));
  }
}

// ---------- LATAR MENU / PETUNJUK / PILIH LEVEL ----------
void latarMenu() {
  gradien(color(100, 180, 255), color(215, 240, 255));
  awan(waktuAnimasi * 10, color(255, 255, 255, 210), 40, 6);
  bukit(waktuAnimasi * 10, 470, 110, 420, color(120, 200, 140));
  bukit(waktuAnimasi * 25, 540, 90, 300, color(70, 170, 90));
  noFill();
  stroke(255, 255, 255, 170);
  strokeWeight(4);
  beginShape();
  curveVertex(0, 628);
  curveVertex(0, 628);
  curveVertex(VW * 0.25, 614 + sin(waktuAnimasi) * 4);
  curveVertex(VW * 0.5, 632);
  curveVertex(VW * 0.75, 614 + cos(waktuAnimasi) * 4);
  curveVertex(VW, 628);
  curveVertex(VW, 628);
  endShape();
  noStroke();
}

// ---------- LEVEL 1: PADANG HUJAN ----------
// Langit mendung, awan gelap, bukit hijau berlapis, siluet pohon, dan kabut tipis.
void latarLevel1() {
  gradien(color(38, 48, 68), color(120, 145, 165));
  awan(cameraX * 0.15, color(48, 56, 74, 235), 18, 8);
  awan(cameraX * 0.30, color(66, 76, 96, 220), 78, 7);
  bukit(cameraX * 0.10, 400, 130, 520, color(70, 92, 105));
  bukit(cameraX * 0.22, 470, 110, 380, color(48, 92, 80));
  bukit(cameraX * 0.38, 540, 80, 300, color(38, 100, 58));
  barisPohon(cameraX * 0.55, 600, 140, 110, color(26, 64, 40), color(0, 0, 0, 0));
  noStroke();
  fill(170, 190, 205, 40);
  rect(0, 430, VW, VH - 430);
}

// ---------- LEVEL 2: GUNUNG ES / SALJU ----------
// Langit biru pucat, matahari berkabut, tiga lapis gunung bersalju, bukit salju, cemara bersalju.
void latarLevel2() {
  gradien(color(120, 170, 220), color(235, 245, 255));
  noStroke();
  fill(255, 255, 255, 70);
  ellipse(VW * 0.78, 110, 190, 190);
  fill(255, 255, 255, 120);
  ellipse(VW * 0.78, 110, 100, 100);
  awan(cameraX * 0.10, color(255, 255, 255, 190), 40, 6);
  gunung(cameraX * 0.08, 430, 300, 420, 360, color(120, 150, 190), color(250, 252, 255));
  gunung(cameraX * 0.18, 500, 240, 380, 300, color(95, 125, 170), color(255));
  gunung(cameraX * 0.30, 560, 170, 300, 240, color(70, 100, 145), color(255));
  bukit(cameraX * 0.40, 590, 50, 320, color(235, 245, 255));
  barisPohon(cameraX * 0.55, 612, 130, 100, color(30, 70, 70), color(255, 255, 255, 230));
}

// ---------- LEVEL 3: ISTANA ES ----------
// Langit malam kutub dengan bintang dan aurora, istana es berkilau, bukit es, duri kristal es.
void latarLevel3() {
  gradien(color(18, 28, 70), color(150, 210, 235));
  bintang(cameraX);
  aurora(cameraX * 0.15, 90, 40, color(80, 255, 170, 34), 0);
  aurora(cameraX * 0.15, 150, 35, color(80, 180, 255, 30), 2);
  aurora(cameraX * 0.15, 60, 30, color(190, 110, 255, 28), 4);
  gunung(cameraX * 0.10, 470, 230, 420, 380, color(70, 100, 160), color(225, 245, 255));
  istanaEs(cameraX * 0.22, 560, 950, 1.0, color(105, 150, 205), color(255, 245, 190));
  bukit(cameraX * 0.40, 600, 40, 300, color(205, 235, 250));
  kristalEs(cameraX * 0.50, 645, 170, 120, color(170, 225, 255, 200));
}

// ---------- LEVEL 4: GOA KRISTAL ----------
// Dinding goa gelap dengan stalaktit/stalagmit berlapis dan kristal warna-warni yang berdenyut.
void latarLevel4() {
  gradien(color(8, 8, 18), color(30, 22, 48));
  stalaktitLatar(cameraX * 0.10, 90, 200, color(18, 16, 34), true);
  stalaktitLatar(cameraX * 0.12, 110, 160, color(18, 16, 34), false);
  kristalGoa(cameraX * 0.20, 300, 11, 1);
  stalaktitLatar(cameraX * 0.28, 70, 130, color(30, 26, 52), true);
  stalaktitLatar(cameraX * 0.30, 90, 110, color(30, 26, 52), false);
  kristalGoa(cameraX * 0.40, 340, 17, 7);
}

// ---------- LEVEL 5: GUNUNG BERAPI MELETUS ----------
// Lereng gelap, kawah menyala, aliran lava, semburan lava berpijar, dan asap tebal. Dipanggil dengan paralaks (g).
void gunungMeletus(float g) {
  float jarak = 1500;
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g + 650;
    float yb = 560;
    float yk = 250 + acak(id * 2.7) * 40;
    float denyut = 0.6 + 0.4 * sin(waktuAnimasi * 1.6 + id);
    noStroke();

    // cahaya kemerahan di langit sekitar kawah
    fill(255, 90, 10, 28 * denyut);
    ellipse(x, yk, 620, 380);
    fill(255, 120, 20, 30 * denyut);
    ellipse(x, yk, 320, 200);

    // asap membumbung dan melebar
    for (int k = 0; k < 12; k++) {
      float t = (waktuAnimasi * 0.18 + k / 12.0) % 1;
      float ax = x + sin(k * 1.9 + waktuAnimasi * 0.5) * 30 + t * 90;
      float ay = yk - 10 - t * 230;
      fill(55, 40, 38, 150 * (1 - t));
      ellipse(ax, ay, 50 + t * 120, 38 + t * 80);
    }

    // badan gunung
    fill(46, 20, 14);
    beginShape();
    vertex(x - 400, yb);
    bezierVertex(x - 260, yb - 40, x - 140, yk + 60, x - 62, yk);
    vertex(x + 62, yk);
    bezierVertex(x + 140, yk + 60, x + 260, yb - 40, x + 400, yb);
    endShape(CLOSE);

    // aliran lava menuruni lereng
    noFill();
    strokeWeight(5);
    for (int sd = -1; sd <= 1; sd += 2) {
      stroke(255, 110, 20, 210);
      beginShape();
      for (int k = 0; k <= 8; k++) {
        float t = k / 8.0;
        vertex(x + sd * (45 + t * 190) + sin(t * 9 + waktuAnimasi * 2 + sd) * 6, yk + 8 + t * (yb - yk - 30));
      }
      endShape();
    }
    noStroke();

    // kawah menyala
    fill(255, 150, 30, 235);
    ellipse(x, yk, 124, 26);
    fill(255, 230, 120, 120 + 100 * denyut);
    ellipse(x, yk, 80, 14);

    // semburan lava berpijar (letusan berdenyut)
    for (int k = 0; k < 36; k++) {
      float t = (waktuAnimasi * 0.6 + acak(k * 1.37 + id) * 3.0) % 1.0;
      float vx0 = (acak(k * 7.1) * 2 - 1) * 190;
      float vy0 = (300 + acak(k * 3.3) * 150) * (0.7 + 0.5 * denyut);
      float px = x + vx0 * t;
      float py = yk - vy0 * t + 420 * t * t;
      float sz = 4 + (1 - t) * 7;
      fill(255, 170 - 100 * t, 20, 255 * (1 - t));
      ellipse(px, py, sz, sz);
    }
  }
}
