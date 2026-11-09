// =====================================================
// LEVEL 1 - PADANG HUJAN
// File ini berisi data level, susunan objek (platform, duri, koin), dan pengaturan tema.
// Tema level: hujan dengan lantai yang normal (tidak licin).
// =====================================================

// Menyimpan data Level 1: nama, tujuan, aturan, ukuran dunia, cuaca, musik, dan warna.
// Data dikembalikan dalam bentuk objek Level.
Level infoLevel1() {
  Level L = new Level();

  // Identitas dan teks yang ditampilkan pada level
  L.id = 1;
  L.nama = "PADANG HUJAN";
  L.tujuan = "Kumpulkan koin, aktifkan checkpoint, lalu capai portal hijau di ujung padang.";
  L.tip = "Tip: lompat di ujung platform untuk jarak lompatan terjauh.";

  // Daftar aturan yang muncul pada popup sebelum level dimulai
  L.aturan = new String[] {
    "Gerak: A / D atau panah. Lompat: SPASI / W / panah atas.",
    "Duri merah berbahaya! Menyentuhnya mengurangi 1 nyawa.",
    "Koin = +100 poin. Bendera checkpoint = +250 poin.",
    "Jatuh ke jurang juga mengurangi nyawa. Nyawa habis = game over."
  };

  // Lebar dunia level serta posisi checkpoint (cpX, cpY) dan ketinggian portal keluar (exitY)
  L.lebar = 2800;
  L.cpX = 1690;
  L.cpY = 560;
  L.exitY = 510;

  // Fisika, cuaca, dan musik. Traksi 1.0 berarti lantai normal (makin kecil makin licin)
  L.traksi = 1.0;
  L.tipeCuaca = C_HUJAN;
  L.indexBgm = 1;

  // Warna tanah, rumput di atas platform, pencahayaan, dan warna langit
  L.cTanah = color(120, 80, 45);
  L.cAtas = color(55, 150, 60);
  L.cAmbient = color(120, 130, 150);
  L.cSinar = color(200, 210, 230);
  L.langitA = color(60, 75, 100);
  L.langitB = color(140, 165, 185);
  return L;
}

// Menyusun semua objek yang ada di Level 1: platform, duri, dan koin.
void bangunLevel1() {
  // Platform dengan format (x, y, lebar, tinggi).
  // Platform tebal (tinggi 100) berfungsi sebagai tanah, yang tipis (tinggi 25) sebagai pijakan melayang.
  platforms.add(new Platform(0, 560, 420, 100));
  platforms.add(new Platform(510, 560, 280, 100));
  platforms.add(new Platform(880, 500, 180, 25));
  platforms.add(new Platform(1120, 440, 190, 25));
  platforms.add(new Platform(1370, 500, 240, 25));
  platforms.add(new Platform(1690, 560, 260, 100));
  platforms.add(new Platform(2010, 500, 180, 25));
  platforms.add(new Platform(2250, 440, 200, 25));
  platforms.add(new Platform(2510, 560, 290, 100));

  // Rintangan berupa duri di lantai, dengan format (x, y, jumlah duri).
  // Level 1 tidak memakai platform bergerak maupun stalaktit.
  tambahDuri(250, 560, 5);
  tambahDuri(610, 560, 3);
  tambahDuri(1850, 560, 3);
  tambahDuri(2590, 560, 3);

  // Koin yang bisa dikumpulkan, format (x, y). Tiap koin bernilai +100 skor.
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
}
