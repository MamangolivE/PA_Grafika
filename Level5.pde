// LEVEL 5 - KAWAH LAVA
// Fungsi infoLevel sbg data awal
Level infoLevel5() {
  Level L = new Level();
  L.id = 5;
  L.nama = "KAWAH LAVA";
  L.tujuan = "Lompati platform di atas lautan lava panas. Hindari jatuh ke dasar arena.";
  L.tip = "Tip: Perhatikan jeda waktu (timing) saat melompat di platform yang bergerak cepat.";
   // Daftar aturan yang tampil di popup.
  L.aturan = new String[] {
    "Dasar arena dipenuhi oleh aliran lava bersuhu tinggi.",
    "Jatuh dan menyentuh permukaan lava akan langsung mengurangi nyawa pemain.",
    "Berhati-hatilah, platform dinamis memiliki kecepatan yang cukup tinggi.",
    "Tetap fokus dan capai portal hijau di ujung arena untuk memenangkan level."
  };
  
  // Konfigurasi ukuran arena, posisi checkpoint, dan titik portal keluar
  L.lebar = 4200;
  L.cpX = 2100;
  L.cpY = 500;   
  L.exitY = 420; 
  
  // Konfigurasi fisika lingkungan dan musik latar
  L.traksi = 0.8; 
  L.tipeCuaca = C_NONE;
  L.indexBgm = 4; 
  
  // Pengaturan palet warna untuk tema kawah vulkanik (merah, oranye, dan coklat)
  L.cTanah = color(50, 20, 15);
  L.cAtas = color(90, 30, 20);
  L.cAmbient = color(180, 70, 50);
  L.cSinar = color(255, 160, 80);
  L.langitA = color(60, 10, 5);
  L.langitB = color(140, 40, 10);
  
  return L;
}

// Prosedur untuk membangun dan memposisikan platform, rintangan, dan koin
void bangunLevel5() {
  // Penyesuaian batas Y agar pemain dapat mendarat tepat di atas permukaan platform pertama
  platforms.add(new Platform(0, 560, 300, 100));
  platforms.add(new MovingPlatform(400, 500, 150, 25, 120, 2.0));
  platforms.add(new Platform(680, 430, 150, 25));
  platforms.add(new Platform(950, 500, 180, 25));
  platforms.add(new MovingPlatform(1250, 450, 140, 25, 150, 2.5));
  platforms.add(new Platform(1600, 500, 250, 100));
  
  // Platform statis sebagai area aman untuk titik checkpoint
  platforms.add(new Platform(2000, 500, 250, 100));
  
  // Rangkaian tantangan platform dinamis setelah melewati checkpoint
  platforms.add(new MovingPlatform(2400, 450, 140, 25, 140, 2.8));
  platforms.add(new Platform(2750, 520, 150, 25));
  platforms.add(new Platform(3000, 450, 150, 25));
  platforms.add(new MovingPlatform(3300, 400, 140, 25, 150, 3.0));
  
  // Platform akhir sebagai landasan untuk portal keluar
  platforms.add(new Platform(3750, 470, 350, 100));

  // Instansiasi duri dasar layar telah dihapus; kekalahan pemain murni bergantung pada persinggungan dengan lava
  
  // Penambahan rintangan duri pada permukaan platform tertentu
  tambahDuri(1650, 500, 3);
  tambahDuri(3800, 470, 4);

  // Distribusi item koin di sepanjang arena untuk perolehan skor tambahan
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

// Prosedur untuk merender latar belakang Level 5 beserta animasi gelombang lava interaktif
void latarLevel5() {
  // Implementasi gradien pada langit untuk merepresentasikan suhu tinggi
  gradien(lv.langitA, lv.langitB);
  
  // Penerapan tiga lapisan siluet pegunungan menggunakan kurva Bezier untuk memberikan efek kedalaman (parallax)
  bukit(cameraX * 0.1, 380, 150, 600, color(40, 15, 10));
  bukit(cameraX * 0.2, 450, 120, 450, color(60, 20, 15));
  bukit(cameraX * 0.3, 520, 90, 300, color(80, 25, 15)); 
  
  // Pembangkitan partikel bara api yang melayang dari arah bawah ke atas
  // Penggunaan randomSeed untuk mempertahankan konsistensi distribusi posisi partikel secara pseudorandom
  randomSeed(5);
  noStroke();
  for(int i = 0; i < 40; i++) {
    float px = wrap(random(width * 2) - cameraX * 0.5, width + 100) - 50;
    float py = wrap(random(height) - waktuAnimasi * (20 + random(10)), height + 50) - 20;
    fill(255, random(100, 200), 0, random(50, 150));
    ellipse(px, py, random(3, 8), random(3, 8));
  }
  
  // Pembangkitan efek percikan magma (lava splashes) secara dinamis di sekitar permukaan
  randomSeed(15);
  for (int i = 0; i < 30; i++) {
    float px = wrap(random(width * 2) - cameraX * 0.6, width + 100) - 50;
    float siklus = (waktuAnimasi * random(1.5, 3.5) + i * 10) % 60;
    
    // Merender percikan hanya pada fase awal siklus untuk menyimulasikan letupan singkat
    if (siklus < 20) {
      float py = 600 + sin(waktuAnimasi * 2.0 + px) * 10 - (siklus * 2.5);
      float alphaPercikan = map(siklus, 0, 20, 255, 0);
      fill(255, random(120, 200), 0, alphaPercikan);
      ellipse(px, py, random(4, 7), random(6, 12));
    }
  }
  randomSeed(millis()); // Mengembalikan instansiasi seed ke fungsi millis() agar nilai acak berikutnya tetap dinamis
  
  // --- LAPISAN LAVA BELAKANG (Warna lebih gelap dengan laju pergerakan lambat) ---
  fill(180, 40, 5, 200);
  float xLavaB = - (cameraX * 0.3) % 150;
  beginShape();
  vertex(xLavaB - 150, height);
  vertex(xLavaB - 150, 590);
  
  // Perulangan untuk membentuk gelombang secara dinamis menggunakan fungsi bezierVertex
  for(float i = xLavaB; i <= width + 150; i += 150) {
     float yWave = 590 + sin(waktuAnimasi * 1.5 + i) * 15;
     bezierVertex(i + 50, yWave - 20, i + 100, yWave + 20, i + 150, yWave);
  }
  vertex(width + 150, height);
  endShape(CLOSE);
  
  // --- LAPISAN LAVA DEPAN (Warna lebih terang dengan laju pergerakan lebih cepat) ---
  fill(230, 60, 10, 220);
  float xLavaD = - (cameraX * 0.5) % 120;
  beginShape();
  vertex(xLavaD - 120, height);
  vertex(xLavaD - 120, 610);
  for(float i = xLavaD; i <= width + 120; i += 120) {
     float yWave = 610 + cos(waktuAnimasi * 3.0 + i) * 12;
     bezierVertex(i + 40, yWave - 15, i + 80, yWave + 15, i + 120, yWave);
  }
  vertex(width + 120, height);
  endShape(CLOSE);
  
  // Pemberian efek pendaran cahaya panas (glow) yang berdenyut menggunakan fungsi sinusoidal
  float glowPanas = 150 + sin(waktuAnimasi * 4) * 40;
  fill(255, 90, 0, glowPanas / 4);
  rect(0, 560, width, height - 560);
}
