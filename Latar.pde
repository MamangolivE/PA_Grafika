// =====================================================
// LATAR (BACKGROUND) PROSEDURAL
// File ini berisi semua gambar latar untuk menu dan Level 1 sampai 5.
// Latar digambar langsung dari bentuk dasar (bezier, triangle, quad, ellipse)
// dan dibuat berlapis dengan efek paralaks, sama seperti latar Level 5,
// sehingga tidak memerlukan file gambar. Setiap level punya tema masing-masing.
//
// Catatan: parameter "g" pada fungsi-fungsi di bawah adalah nilai geseran latar,
// yaitu posisi kamera yang dikalikan faktor paralaks. Lapisan yang lebih jauh
// memakai faktor kecil sehingga bergeraknya lebih pelan.
// =====================================================

// ---------- FUNGSI BANTU ----------

// Menghasilkan bilangan acak semu antara 0 sampai 1 dari angka masukan n.
// Hasilnya selalu sama untuk n yang sama, jadi bentuk latar tidak berubah-ubah tiap frame.
float acak(float n) {
  float v = sin(n * 12.9898) * 43758.5453;
  return v - floor(v);
}

// ---------- ELEMEN LATAR ----------

// Menggambar barisan pohon cemara dalam bentuk siluet.
// yBase = garis tanah, jarak = jarak antar pohon, tinggi = tinggi rata-rata pohon,
// c = warna pohon, salju = warna salju di tiap tingkat daun (alpha 0 berarti tanpa salju).
void barisPohon(float g, float yBase, float jarak, float tinggi, color c, color salju) {
  int i0 = floor(g / jarak);         // nomor pohon paling kiri yang masih terlihat
  int n = ceil(VW / jarak) + 2;      // jumlah pohon yang digambar (+2 agar tepi layar tidak kosong)
  noStroke();
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    // Posisi x ikut bergeser sesuai g, ditambah sedikit acak supaya letak pohon tidak lurus
    float x = id * jarak - g + acak(id * 5.3) * jarak * 0.4;
    // Tinggi tiap pohon dibuat berbeda-beda
    float h = tinggi * (0.7 + 0.5 * acak(id * 2.9));
    fill(c);
    rect(x - 2, yBase - h * 0.12, 4, h * 0.12 + 2); // batang pohon
    // Daun pohon terdiri dari 3 tingkat segitiga, makin ke atas makin kecil
    for (int k = 0; k < 3; k++) {
      float w = h * 0.34 * (1 - k * 0.25);   // setengah lebar alas segitiga
      float yb = yBase - h * 0.28 * k - h * 0.12; // sisi bawah tingkat
      float yt = yb - h * 0.42;                   // ujung atas tingkat
      fill(c);
      triangle(x - w, yb, x + w, yb, x, yt);
      // Jika warna salju tidak transparan, bagian puncak tiap tingkat diberi salju
      if (alpha(salju) > 0) {
        fill(salju);
        float y0 = yb - (yb - yt) * 0.45;
        triangle(x - w * 0.55, y0, x + w * 0.55, y0, x, yt);
      }
    }
  }
}

// Menggambar barisan gunung berbentuk segitiga lengkap dengan puncak salju dan sisi bayangan.
// tinggi dan lebar = ukuran rata-rata gunung, jarak = jarak antar gunung,
// body = warna badan gunung, salju = warna salju di puncak.
void gunung(float g, float yBase, float tinggi, float lebar, float jarak, color body, color salju) {
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  noStroke();
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g;
    // Tinggi dan lebar tiap gunung dibuat bervariasi dengan nilai acak
    float t = tinggi * (0.65 + 0.35 * acak(id * 3.1 + yBase));
    float w = lebar * (0.8 + 0.4 * acak(id * 1.7 + 4));
    // Badan gunung
    fill(body);
    triangle(x - w / 2, yBase, x + w / 2, yBase, x, yBase - t);
    // Bayangan di sisi kanan gunung (hitam transparan)
    fill(0, 0, 0, 32);
    triangle(x, yBase - t, x + w / 2, yBase, x, yBase);
    // Puncak salju berbentuk poligon dengan tepi bergerigi
    float p = 0.32; // proporsi bagian gunung yang tertutup salju
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
  // Mengisi bagian bawah gunung sampai dasar layar agar tidak ada celah
  fill(body);
  rect(0, yBase - 1, VW, VH - yBase + 2);
}

// Menggambar pita aurora yang bergelombang di langit Istana Es.
// y0 = tinggi dasar pita, amp = besar gelombang, c = warna pita, fase = pergeseran gelombang.
void aurora(float g, float y0, float amp, color c, float fase) {
  noStroke();
  fill(c);
  beginShape(TRIANGLE_STRIP);
  for (float x = 0; x <= VW + 30; x += 30) {
    // Dua gelombang sinus digabung agar gerakannya terlihat lebih alami,
    // waktuAnimasi membuat pita bergerak pelan seiring waktu
    float yy = y0 + sin((x + g) * 0.006 + waktuAnimasi * 0.6 + fase) * amp
      + sin((x + g) * 0.013 + waktuAnimasi * 0.3) * amp * 0.4;
    vertex(x, yy);                                   // tepi atas pita
    vertex(x, yy + 110 + sin(x * 0.02 + fase) * 20); // tepi bawah pita
  }
  endShape();
}

// Menggambar 70 bintang di langit malam. Alpha-nya berubah mengikuti waktu sehingga tampak berkelip.
void bintang(float g) {
  noStroke();
  for (int i = 0; i < 70; i++) {
    // Posisi tetap per bintang; wrap() membuat bintang muncul kembali dari sisi lain saat keluar layar
    float x = wrap(acak(i) * VW * 1.5 - g * 0.05, VW);
    float y = acak(i + 100) * 300;
    fill(255, 255, 255, 150 + 100 * sin(waktuAnimasi * 3 + i));
    ellipse(x, y, 2 + acak(i + 50) * 2, 2 + acak(i + 50) * 2);
  }
}

// Menggambar istana es: badan utama, gerigi di atas tembok, menara tengah dan dua menara samping
// beratap runcing, serta jendela dan gerbang yang bercahaya.
// s = skala ukuran istana, c = warna es, terang = warna cahaya jendela dan gerbang.
void istanaEs(float g, float yBase, float jarak, float s, color c, color terang) {
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  noStroke();
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g + jarak * 0.5;
    fill(c);
    rect(x - 75 * s, yBase - 150 * s, 150 * s, 150 * s); // badan utama istana
    // Gerigi di bagian atas tembok
    for (int k = 0; k < 6; k++) {
      rect(x - 75 * s + k * 25 * s, yBase - 162 * s, 14 * s, 12 * s);
    }
    // Menara tengah beserta atapnya
    rect(x - 22 * s, yBase - 250 * s, 44 * s, 250 * s);
    triangle(x - 28 * s, yBase - 250 * s, x + 28 * s, yBase - 250 * s, x, yBase - 330 * s);
    // Menara kiri dan kanan (sd = -1 untuk kiri, sd = 1 untuk kanan)
    for (int sd = -1; sd <= 1; sd += 2) {
      float tx = x + sd * 95 * s;
      rect(tx - 20 * s, yBase - 200 * s, 40 * s, 200 * s);
      triangle(tx - 26 * s, yBase - 200 * s, tx + 26 * s, yBase - 200 * s, tx, yBase - 265 * s);
      fill(terang);
      rect(tx - 5 * s, yBase - 160 * s, 10 * s, 22 * s, 5 * s); // jendela menara samping
      fill(c);
    }
    // Jendela bercahaya pada menara tengah dan badan utama
    fill(terang);
    rect(x - 6 * s, yBase - 215 * s, 12 * s, 26 * s, 6 * s);
    rect(x - 50 * s, yBase - 110 * s, 12 * s, 24 * s, 6 * s);
    rect(x + 38 * s, yBase - 110 * s, 12 * s, 24 * s, 6 * s);
    // Gerbang istana (sudut atasnya dibulatkan)
    fill(terang, 200);
    rect(x - 16 * s, yBase - 48 * s, 32 * s, 48 * s, 16 * s, 16 * s, 0, 0);
    // Garis putih transparan di sisi menara tengah sebagai kesan kilau es
    fill(255, 255, 255, 45);
    rect(x - 22 * s, yBase - 250 * s, 10 * s, 250 * s);
  }
  // Mengisi bagian bawah sampai dasar layar
  fill(c);
  rect(0, yBase - 1, VW, VH - yBase + 2);
}

// Menggambar duri kristal es yang mencuat dari bawah, sebagai latar paling depan di istana es.
void kristalEs(float g, float yBase, float jarak, float tinggi, color c) {
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  noStroke();
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g;
    float h = tinggi * (0.4 + 0.9 * acak(id * 4.1)); // tinggi kristal acak
    float w = 26 + acak(id * 6.7) * 24;              // lebar kristal acak
    fill(c);
    triangle(x - w, yBase + 10, x + w, yBase + 10, x, yBase - h);
    // Separuh kiri diberi warna putih transparan agar tampak mengilap
    fill(255, 255, 255, 90);
    triangle(x - w, yBase + 10, x, yBase + 10, x, yBase - h);
  }
}

// Menggambar stalaktit (menggantung dari atas, jika dariAtas = true) atau
// stalagmit (menjulang dari bawah, jika false) sebagai siluet dinding goa.
// panjang = panjang rata-rata, c = warna siluet.
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
    // Arah segitiga mengikuti jenisnya: ke bawah dari langit-langit atau ke atas dari lantai
    if (dariAtas) triangle(x, -2, x + w, -2, x + w * 0.5, len);
    else triangle(x, VH + 2, x + w, VH + 2, x + w * 0.5, VH - len);
  }
  // Pita tipis di tepi atas atau bawah agar pangkal segitiga tersambung
  if (dariAtas) rect(0, -2, VW, 18);
  else rect(0, VH - 16, VW, 18);
}

// Menggambar gugusan kristal bercahaya di dinding goa. Cahayanya berdenyut mengikuti waktu.
// s = ukuran kristal, seed = angka pembeda agar tiap lapisan punya letak dan warna yang berbeda.
void kristalGoa(float g, float jarak, float s, int seed) {
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  // Pilihan warna kristal: biru muda, ungu, biru, dan hijau toska
  color[] pal = {color(90, 210, 255), color(225, 100, 255), color(110, 150, 255), color(90, 255, 205)};
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g + acak(id * 3.3 + seed) * jarak * 0.6;
    float y = 150 + acak(id * 1.9 + seed) * 420;
    color c = pal[(id + seed) % 4];
    float k = 0.6 + 0.4 * sin(waktuAnimasi * 2 + id * 1.3); // nilai denyut cahaya
    noStroke();
    // Dua lingkaran transparan sebagai pendar cahaya di sekitar kristal
    fill(red(c), green(c), blue(c), 28 * k);
    ellipse(x, y, s * 9, s * 9);
    fill(red(c), green(c), blue(c), 45 * k);
    ellipse(x, y, s * 5, s * 5);
    // Satu kristal besar dan dua kristal kecil di sampingnya (fungsi kristal() ada di file lain)
    kristal(x, y, s, color(red(c), green(c), blue(c), 190 + 50 * k));
    kristal(x + s * 1.2, y + s * 0.9, s * 0.6, color(red(c), green(c), blue(c), 170 + 50 * k));
    kristal(x - s * 1.1, y + s * 1.1, s * 0.5, color(red(c), green(c), blue(c), 160 + 50 * k));
  }
}

// ---------- LATAR MENU / PETUNJUK / PILIH LEVEL ----------
// Langit biru cerah dengan awan dan dua lapis bukit hijau yang bergerak pelan,
// ditambah garis putih bergelombang di bagian bawah.
void latarMenu() {
  gradien(color(100, 180, 255), color(215, 240, 255));
  awan(waktuAnimasi * 10, color(255, 255, 255, 210), 40, 6);
  bukit(waktuAnimasi * 10, 470, 110, 420, color(120, 200, 140));
  bukit(waktuAnimasi * 25, 540, 90, 300, color(70, 170, 90));
  // Garis putih bergelombang (kesannya seperti aliran air atau jalan)
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
  // Dua lapis awan gelap, yang depan bergerak lebih cepat
  awan(cameraX * 0.15, color(48, 56, 74, 235), 18, 8);
  awan(cameraX * 0.30, color(66, 76, 96, 220), 78, 7);
  // Tiga lapis bukit dari yang terjauh sampai yang terdekat
  bukit(cameraX * 0.10, 400, 130, 520, color(70, 92, 105));
  bukit(cameraX * 0.22, 470, 110, 380, color(48, 92, 80));
  bukit(cameraX * 0.38, 540, 80, 300, color(38, 100, 58));
  // Pohon tanpa salju (warna salju dibuat transparan)
  barisPohon(cameraX * 0.55, 600, 140, 110, color(26, 64, 40), color(0, 0, 0, 0));
  // Kabut tipis di bagian bawah layar
  noStroke();
  fill(170, 190, 205, 40);
  rect(0, 430, VW, VH - 430);
}

// ---------- LEVEL 2: GUNUNG ES / SALJU ----------
// Langit biru pucat, matahari berkabut, tiga lapis gunung bersalju, bukit salju, dan cemara bersalju.
void latarLevel2() {
  gradien(color(120, 170, 220), color(235, 245, 255));
  // Matahari berkabut dari dua lingkaran putih transparan
  noStroke();
  fill(255, 255, 255, 70);
  ellipse(VW * 0.78, 110, 190, 190);
  fill(255, 255, 255, 120);
  ellipse(VW * 0.78, 110, 100, 100);
  awan(cameraX * 0.10, color(255, 255, 255, 190), 40, 6);
  // Tiga lapis gunung, yang paling belakang paling pucat dan bergerak paling pelan
  gunung(cameraX * 0.08, 430, 300, 420, 360, color(120, 150, 190), color(250, 252, 255));
  gunung(cameraX * 0.18, 500, 240, 380, 300, color(95, 125, 170), color(255));
  gunung(cameraX * 0.30, 560, 170, 300, 240, color(70, 100, 145), color(255));
  bukit(cameraX * 0.40, 590, 50, 320, color(235, 245, 255));
  // Cemara dengan salju putih di tiap tingkatnya
  barisPohon(cameraX * 0.55, 612, 130, 100, color(30, 70, 70), color(255, 255, 255, 230));
}

// ---------- LEVEL 3: ISTANA ES ----------
// Langit malam kutub dengan bintang dan aurora, istana es yang berkilau, bukit es, dan duri kristal es.
void latarLevel3() {
  gradien(color(18, 28, 70), color(150, 210, 235));
  bintang(cameraX);
  // Tiga pita aurora dengan warna hijau, biru, dan ungu
  aurora(cameraX * 0.15, 90, 40, color(80, 255, 170, 34), 0);
  aurora(cameraX * 0.15, 150, 35, color(80, 180, 255, 30), 2);
  aurora(cameraX * 0.15, 60, 30, color(190, 110, 255, 28), 4);
  gunung(cameraX * 0.10, 470, 230, 420, 380, color(70, 100, 160), color(225, 245, 255));
  istanaEs(cameraX * 0.22, 560, 950, 1.0, color(105, 150, 205), color(255, 245, 190));
  bukit(cameraX * 0.40, 600, 40, 300, color(205, 235, 250));
  kristalEs(cameraX * 0.50, 645, 170, 120, color(170, 225, 255, 200));
}

// ---------- LEVEL 4: GOA KRISTAL ----------
// Dinding goa yang gelap dengan stalaktit dan stalagmit berlapis, serta kristal warna-warni yang berdenyut.
void latarLevel4() {
  gradien(color(8, 8, 18), color(30, 22, 48));
  // Lapisan jauh: stalaktit (atas) dan stalagmit (bawah) berwarna paling gelap
  stalaktitLatar(cameraX * 0.10, 90, 200, color(18, 16, 34), true);
  stalaktitLatar(cameraX * 0.12, 110, 160, color(18, 16, 34), false);
  kristalGoa(cameraX * 0.20, 300, 11, 1);
  // Lapisan dekat: lebih terang, lebih rapat, dan bergerak lebih cepat
  stalaktitLatar(cameraX * 0.28, 70, 130, color(30, 26, 52), true);
  stalaktitLatar(cameraX * 0.30, 90, 110, color(30, 26, 52), false);
  kristalGoa(cameraX * 0.40, 340, 17, 7);
}

// ---------- LEVEL 5: GUNUNG BERAPI MELETUS ----------
// Menggambar gunung berapi yang sedang meletus: lereng gelap, kawah menyala, aliran lava,
// semburan lava berpijar, dan asap tebal. Dipanggil dari latarLevel5() dengan nilai paralaks g.
void gunungMeletus(float g) {
  float jarak = 1500; // jarak antar gunung
  int i0 = floor(g / jarak);
  int n = ceil(VW / jarak) + 2;
  for (int i = 0; i < n; i++) {
    int id = i0 + i;
    float x = id * jarak - g + 650;
    float yb = 560;                           // dasar gunung
    float yk = 250 + acak(id * 2.7) * 40;     // tinggi kawah, sedikit berbeda tiap gunung
    float denyut = 0.6 + 0.4 * sin(waktuAnimasi * 1.6 + id); // nilai denyut untuk cahaya dan letusan
    noStroke();

    // Cahaya kemerahan di langit sekitar kawah
    fill(255, 90, 10, 28 * denyut);
    ellipse(x, yk, 620, 380);
    fill(255, 120, 20, 30 * denyut);
    ellipse(x, yk, 320, 200);

    // Asap yang naik dari kawah, makin ke atas makin besar dan makin transparan
    for (int k = 0; k < 12; k++) {
      float t = (waktuAnimasi * 0.18 + k / 12.0) % 1; // posisi asap pada siklus naik (0 sampai 1)
      float ax = x + sin(k * 1.9 + waktuAnimasi * 0.5) * 30 + t * 90;
      float ay = yk - 10 - t * 230;
      fill(55, 40, 38, 150 * (1 - t));
      ellipse(ax, ay, 50 + t * 120, 38 + t * 80);
    }

    // Badan gunung, dibentuk dengan kurva bezier di kedua sisinya
    fill(46, 20, 14);
    beginShape();
    vertex(x - 400, yb);
    bezierVertex(x - 260, yb - 40, x - 140, yk + 60, x - 62, yk);
    vertex(x + 62, yk);
    bezierVertex(x + 140, yk + 60, x + 260, yb - 40, x + 400, yb);
    endShape(CLOSE);

    // Aliran lava yang mengalir menuruni lereng kiri dan kanan (sd = -1 kiri, sd = 1 kanan)
    noFill();
    strokeWeight(5);
    for (int sd = -1; sd <= 1; sd += 2) {
      stroke(255, 110, 20, 210);
      beginShape();
      for (int k = 0; k <= 8; k++) {
        float t = k / 8.0;
        // Fungsi sin membuat aliran lava sedikit meliuk
        vertex(x + sd * (45 + t * 190) + sin(t * 9 + waktuAnimasi * 2 + sd) * 6, yk + 8 + t * (yb - yk - 30));
      }
      endShape();
    }
    noStroke();

    // Kawah yang menyala (lingkaran oranye dengan inti kuning di tengahnya)
    fill(255, 150, 30, 235);
    ellipse(x, yk, 124, 26);
    fill(255, 230, 120, 120 + 100 * denyut);
    ellipse(x, yk, 80, 14);

    // Semburan lava berpijar. Tiap percikan bergerak melengkung seperti lemparan
    // (kecepatan awal vx0 dan vy0, ditarik turun oleh gravitasi), dan makin kecil serta pudar seiring waktu
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
