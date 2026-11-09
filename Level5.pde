// =====================================================
// LEVEL 5 - KAWAH LAVA
// File ini berisi data level, susunan objek (platform, duri, koin), dan latar level.
// Tema level: gunung berapi dengan lautan lava di bagian bawah.
// =====================================================

// Menyimpan data Level 5: nama, tujuan, aturan, ukuran dunia, musik, dan warna.
// Data dikembalikan dalam bentuk objek Level.
Level infoLevel5() {
  Level L = new Level();

  // Identitas dan teks yang ditampilkan pada level
  L.id = 5;
  L.nama = "KAWAH LAVA";
  L.tujuan = "Lompati platform di atas lautan lava panas. Hindari jatuh ke dasar arena.";
  L.tip = "Tip: Perhatikan jeda waktu (timing) saat melompat di platform yang bergerak cepat.";

  // Daftar aturan yang muncul pada popup sebelum level dimulai
  L.aturan = new String[] {
    "Dasar arena dipenuhi oleh aliran lava bersuhu tinggi.",
    "Jatuh dan menyentuh permukaan lava akan langsung mengurangi nyawa pemain.",
    "Berhati-hatilah, platform dinamis memiliki kecepatan yang cukup tinggi.",
    "Tetap fokus dan capai portal hijau di ujung arena untuk memenangkan level."
  };

  // Lebar dunia level serta posisi checkpoint (cpX, cpY) dan ketinggian portal keluar (exitY)
  L.lebar = 4200;
  L.cpX = 2100;
  L.cpY = 500;   // disesuaikan dengan ketinggian platform checkpoint
  L.exitY = 420; // disesuaikan dengan ketinggian platform terakhir

  // Fisika, cuaca, dan musik
  L.traksi = 0.8; // sedikit lebih licin dari lantai normal, anggap saja karena abu vulkanik
  L.tipeCuaca = C_NONE; // tidak memakai cuaca bawaan, efek lava dibuat sendiri di latarLevel5()
  L.indexBgm = 5; // musik khusus level kawah lava (bgm_level5.wav)

  // Warna tanah, permukaan platform, pencahayaan, dan langit dengan nuansa merah, oranye, dan coklat
  L.cTanah = color(50, 20, 15);
  L.cAtas = color(90, 30, 20);
  L.cAmbient = color(180, 70, 50);
  L.cSinar = color(255, 160, 80);
  L.langitA = color(60, 10, 5);
  L.langitB = color(140, 40, 10);

  return L;
}

// Menyusun semua objek yang ada di Level 5: platform, duri, dan koin.
void bangunLevel5() {
  // Platform dengan format (x, y, lebar, tinggi).
  // MovingPlatform adalah platform yang bergerak, dengan tambahan dua nilai di belakang:
  // jarak gerak dan kecepatan geraknya. Platform pertama diatur agar pemain bisa mendarat dengan pas.
  platforms.add(new Platform(0, 560, 300, 100));
  platforms.add(new MovingPlatform(400, 500, 150, 25, 120, 2.0));
  platforms.add(new Platform(680, 430, 150, 25));
  platforms.add(new Platform(950, 500, 180, 25));
  platforms.add(new MovingPlatform(1250, 450, 140, 25, 150, 2.5));
  platforms.add(new Platform(1600, 500, 250, 100));

  // Platform diam sebagai area aman untuk checkpoint
  platforms.add(new Platform(2000, 500, 250, 100));

  // Rangkaian platform bergerak setelah checkpoint, kecepatannya makin tinggi
  platforms.add(new MovingPlatform(2400, 450, 140, 25, 140, 2.8));
  platforms.add(new Platform(2750, 520, 150, 25));
  platforms.add(new Platform(3000, 450, 150, 25));
  platforms.add(new MovingPlatform(3300, 400, 140, 25, 150, 3.0));

  // Platform terakhir sebagai tempat portal keluar
  platforms.add(new Platform(3750, 470, 350, 100));

  // Duri di dasar layar tidak dipakai di level ini, karena pemain kalah saat menyentuh lava

  // Duri hanya dipasang di atas platform tertentu, format (x, y, jumlah duri)
  tambahDuri(1650, 500, 3);
  tambahDuri(3800, 470, 4);

  // Koin yang tersebar di sepanjang arena untuk menambah skor.
  // Memakai barisKoin dengan format (x, y, jumlah koin, jarak antar koin).
  barisKoin(100, 500, 3, 50);
  barisKoin(430, 440, 3, 40);
  barisKoin(710, 370, 3, 40);
  barisKoin(1000, 440, 3, 40);
  barisKoin(1280, 390, 3, 40);
  barisKoin(1700, 440, 3, 50);
  barisKoin(2430, 390, 3, 40);
  barisKoin(2780, 460, 3, 40);
  barisKoin(3030, 390, 3, 40);
  barisKoin(3330, 340, 3, 40);
}

// Menggambar latar Level 5 beserta animasi lava yang bergelombang.
void latarLevel5() {
  // Langit berupa gradien dari warna langitA ke langitB (suasana panas)
  gradien(lv.langitA, lv.langitB);

  // Tiga lapis bukit gelap dengan kurva bezier agar terlihat berlapis (efek paralaks).
  // Gunung berapi yang meletus (dari file Latar) diletakkan di antara lapisan bukit.
  bukit(cameraX * 0.1, 380, 150, 600, color(40, 15, 10));
  gunungMeletus(cameraX * 0.15); // gunung berapi yang meletus
  bukit(cameraX * 0.2, 450, 120, 450, color(60, 20, 15));
  bukit(cameraX * 0.3, 520, 90, 300, color(80, 25, 15));

  // Partikel bara api yang melayang dari bawah ke atas.
  // randomSeed(5) dipakai supaya urutan angka acaknya selalu sama di tiap frame,
  // sehingga posisi bara tidak loncat-loncat dan geraknya tetap halus.
  randomSeed(5);
  noStroke();
  for(int i = 0; i < 40; i++) {
    float px = wrap(random(VW * 2) - cameraX * 0.5, VW + 100) - 50;
    float py = wrap(random(VH) - waktuAnimasi * (20 + random(10)), VH + 50) - 20;
    fill(255, random(100, 200), 0, random(50, 150));
    ellipse(px, py, random(3, 8), random(3, 8));
  }

  // Percikan lava yang muncul di sekitar permukaan lava, dengan seed yang berbeda dari bara api
  randomSeed(15);
  for (int i = 0; i < 30; i++) {
    float px = wrap(random(VW * 2) - cameraX * 0.6, VW + 100) - 50;
    float siklus = (waktuAnimasi * random(1.5, 3.5) + i * 10) % 60;
    float wr = random(120, 200), sw = random(4, 7), sh = random(6, 12);

    // Percikan hanya digambar pada awal siklus (nilai di bawah 20),
    // jadi tampilannya seperti letupan singkat yang naik lalu memudar
    if (siklus < 20) {
      float py = 600 + sin(waktuAnimasi * 2.0 + i) * 10 - (siklus * 2.5);
      float alphaPercikan = map(siklus, 0, 20, 255, 0);
      fill(255, wr, 0, alphaPercikan);
      ellipse(px, py, sw, sh);
    }
  }
  randomSeed(millis()); // seed dikembalikan ke millis() supaya angka acak di bagian game lain tetap bervariasi

  // --- LAPISAN LAVA BELAKANG (lebih gelap dan bergerak lebih lambat) ---
  fill(180, 40, 5, 200);
  int idB = floor(cameraX * 0.3 / 150);        // nomor gelombang pertama yang terlihat
  float xLavaB = idB * 150 - cameraX * 0.3;    // posisi x gelombang pertama
  beginShape();
  vertex(xLavaB - 150, VH);
  vertex(xLavaB, 590 + sin(waktuAnimasi * 1.5 + (idB - 1) * 1.3) * 15);

  // Perulangan untuk membentuk gelombang lava dengan bezierVertex.
  // Tinggi tiap gelombang dihitung dengan sin() sehingga permukaannya naik turun.
  for(float i = xLavaB, n = idB; i <= VW + 150; i += 150, n++) {
     float yWave = 590 + sin(waktuAnimasi * 1.5 + n * 1.3) * 15;
     bezierVertex(i + 50, yWave - 20, i + 100, yWave + 20, i + 150, yWave);
  }
  vertex(VW + 150, VH);
  endShape(CLOSE);

  // --- LAPISAN LAVA DEPAN (lebih terang dan bergerak lebih cepat) ---
  fill(230, 60, 10, 220);
  int idD = floor(cameraX * 0.5 / 120);        // nomor gelombang pertama yang terlihat
  float xLavaD = idD * 120 - cameraX * 0.5;    // posisi x gelombang pertama
  beginShape();
  vertex(xLavaD - 120, VH);
  vertex(xLavaD, 610 + cos(waktuAnimasi * 3.0 + (idD - 1) * 1.3) * 12);
  for(float i = xLavaD, n = idD; i <= VW + 120; i += 120, n++) {
     float yWave = 610 + cos(waktuAnimasi * 3.0 + n * 1.3) * 12;
     bezierVertex(i + 40, yWave - 15, i + 80, yWave + 15, i + 120, yWave);
  }
  vertex(VW + 120, VH);
  endShape(CLOSE);

  // Cahaya panas dari lava yang berdenyut, dibuat dengan lapisan oranye transparan
  // yang tingkat transparansinya berubah mengikuti fungsi sin()
  float glowPanas = 150 + sin(waktuAnimasi * 4) * 40;
  fill(255, 90, 0, glowPanas / 4);
  rect(0, 560, VW, VH - 560);
}
