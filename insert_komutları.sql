-- Örnek kullanıcılar: 2 öğrenci, 2 eğitmen, 1 admin
INSERT INTO Kullanici (kullanici_id, ad, soyad, email, sifre, rol, kayit_tarihi, aktif) VALUES
(1, '   Ali   ',   'Yılmaz  ', 'ALI.YILMAZ@EXAMPLE.COM  ', '123456', 'ogrenci', '2024-01-10', TRUE),
(2, 'Ayşe',        'Demir',   '  ayse.demir@example.com', '123456', 'ogrenci', '2024-02-05', TRUE),
(3, 'Mehmet',      'Kara',    ' mehmet.kara@example.com ', '123456', 'egitmen', '2024-01-01', TRUE),
(4, 'Zeynep',      'Şahin',   'zeynep.sahin@example.com',  '123456', 'egitmen', '2024-01-15', TRUE),
(5, 'Admin',       'User',    'admin@example.com',         '123456', 'admin',   '2024-01-01', TRUE);

-- Ogrenci: Kullanici 1 ve 2
INSERT INTO Ogrenci (kullanici_id, ogrenci_no, dogum_tarihi) VALUES
(1, '2023001', '2004-03-12'),
(2, '2023002', '2003-11-05');

-- Egitmen: Kullanici 3 ve 4
INSERT INTO Egitmen (kullanici_id, unvan, biyografi) VALUES
(3, 'Dr.', 'Veri tabanları ve SQL konusunda uzman.'),
(4, 'Öğr. Gör.', 'Web geliştirme ve front-end alanında deneyimli.');

INSERT INTO Kategori (kategori_id, ad, aciklama) VALUES
(1, 'Programlama', 'Genel amaçlı programlama dilleri ve yazılım geliştirme.'),
(2, 'Veri Tabanı', 'İlişkisel veritabanları, SQL ve veri modelleme.'),
(3, 'Web Geliştirme', 'Ön yüz ve arka yüz web teknolojileri.');

INSERT INTO Kurs (kurs_id, baslik, aciklama, seviye, fiyat, yayinda, olusturma_tarihi, ortalama_puan, yorum_sayisi) VALUES
(1, 'SQL ve Veritabanı Temelleri',
 'İlişkisel modeller, temel SQL sorguları ve veritabanı tasarımı.',
 'Baslangic', 500.00, TRUE, '2024-01-20', NULL, 0),

(2, 'Web Programlamaya Giriş',
 'HTML, CSS ve temel JavaScript ile web sayfası geliştirme.',
 'Baslangic', 300.00, TRUE, '2024-02-10', NULL, 0);

-- Kurs 1: Programlama + Veri Tabanı
INSERT INTO Kurs_Kategori (kurs_id, kategori_id) VALUES
(1, 1),
(1, 2);

-- Kurs 2: Programlama + Web Geliştirme
INSERT INTO Kurs_Kategori (kurs_id, kategori_id) VALUES
(2, 1),
(2, 3);

-- Kurs 1'i Mehmet ve Zeynep veriyor
INSERT INTO Kurs_Egitmen (kurs_id, egitmen_id) VALUES
(1, 3),
(1, 4);

-- Kurs 2'yi sadece Zeynep veriyor
INSERT INTO Kurs_Egitmen (kurs_id, egitmen_id) VALUES
(2, 4);

-- Kurs 1 için modüller
INSERT INTO Modul (modul_id, kurs_id, baslik, sira_no) VALUES
(1, 1, 'Giriş ve Temel Kavramlar', 1),
(2, 1, 'Temel SQL Komutları',      2);

-- Kurs 2 için modül
INSERT INTO Modul (modul_id, kurs_id, baslik, sira_no) VALUES
(3, 2, 'Web Temelleri', 1);

-- Dersler
INSERT INTO Ders (ders_id, modul_id, baslik, aciklama, video_url, sure_dk, sira_no) VALUES
(1, 1, 'Veritabanı Nedir?', 'Veritabanı kavramına giriş.', 'https://video.example.com/1', 25, 1),
(2, 2, 'SELECT ile Veri Okuma', 'Temel SELECT sorguları.', 'https://video.example.com/2', 35, 1),
(3, 3, 'HTML Temelleri', 'Basit HTML etiketleri.', 'https://video.example.com/3', 30, 1);

INSERT INTO Icerik_Dosya (dosya_id, ders_id, dosya_adi, dosya_turu, dosya_yolu) VALUES
(1, 1, 'veritabani_giris.pdf', 'pdf', '/dosyalar/veritabani_giris.pdf'),
(2, 2, 'select_ornekleri.sql', 'sql', '/dosyalar/select_ornekleri.sql'),
(3, 3, 'html_ornekleri.zip',   'zip', '/dosyalar/html_ornekleri.zip');

-- Ali (1) Kurs 1'e kayıtlı
-- Ayşe (2) Kurs 1 ve Kurs 2'ye kayıtlı
INSERT INTO Kayit (kayit_id, ogrenci_id, kurs_id, kayit_tarihi, durum) VALUES
(1, 1, 1, '2024-03-01', 'aktif'),
(2, 2, 1, '2024-03-05', 'aktif'),
(3, 2, 2, '2024-03-06', 'aktif');

-- Ali Kurs 1 için tam ödeme yapıyor (500 → tamamlandi)
INSERT INTO Odeme (odeme_id, kayit_id, tutar, odeme_tarihi, odeme_yontemi, durum) VALUES
(1, 1, 500.00, '2024-03-02', 'kart', 'tamamlandi');

-- Ayşe Kurs 1 için henüz yarım ödeme yapıyor (300/500 → aktif kalmalı)
INSERT INTO Odeme (odeme_id, kayit_id, tutar, odeme_tarihi, odeme_yontemi, durum) VALUES
(2, 2, 250.00, '2024-03-06', 'kart', 'beklemede');

-- Ayşe Kurs 2 için tam ödeme yapıyor (300 → tamamlandi)
INSERT INTO Odeme (odeme_id, kayit_id, tutar, odeme_tarihi, odeme_yontemi, durum) VALUES
(3, 3, 300.00, '2024-03-07', 'kart', 'tamamlandi');

-- Kurs 1 için bir quiz
INSERT INTO Quiz (quiz_id, kurs_id, baslik, aciklama, yayin_tarihi) VALUES
(1, 1, 'SQL Temel Quiz', 'Temel SQL bilgisi ölçme sınavı.', '2024-03-10');

-- Quiz 1 için sorular
INSERT INTO Soru (soru_id, quiz_id, metin, soru_tipi, zorluk_derecesi) VALUES
(1, 1, 'SELECT sorgusu hangi amaçla kullanılır?', 'coktan_secmeli', 1),
(2, 1, 'WHERE ifadesinin görevi nedir?',              'coktan_secmeli', 2);

-- Soru 1 seçenekleri
INSERT INTO Secenek (secenek_id, soru_id, metin, dogru_mu) VALUES
(1, 1, 'Veri eklemek için', FALSE),
(2, 1, 'Veri silmek için', FALSE),
(3, 1, 'Veri sorgulamak için', TRUE);

-- Soru 2 seçenekleri
INSERT INTO Secenek (secenek_id, soru_id, metin, dogru_mu) VALUES
(4, 2, 'Sorgu sonucunu sıralamak için', FALSE),
(5, 2, 'Belirli şartlara göre filtreleme yapmak için', TRUE),
(6, 2, 'Tablo oluşturmak için', FALSE);

-- Ali (ogrenci_id = 1) iki soruyu da doğru cevaplıyor
INSERT INTO Ogrenci_Cevap (cevap_id, ogrenci_id, soru_id, secenek_id, verilen_cevap_metin, cevap_tarihi) VALUES
(1, 1, 1, 3, NULL, '2024-03-11'),
(2, 1, 2, 5, NULL, '2024-03-11');

-- Ayşe (ogrenci_id = 2) birini yanlış, birini doğru yapıyor
INSERT INTO Ogrenci_Cevap (cevap_id, ogrenci_id, soru_id, secenek_id, verilen_cevap_metin, cevap_tarihi) VALUES
(3, 2, 1, 2, NULL, '2024-03-11'),
(4, 2, 2, 5, NULL, '2024-03-11');

-- Ali Kurs 1 için 5 puan veriyor
INSERT INTO Yorum (yorum_id, ogrenci_id, kurs_id, yorum_metin, puan, yorum_tarihi) VALUES
(1, 1, 1, 'Kurs çok açıklayıcı ve anlaşılırdı.', 5, '2024-03-12');

-- Ayşe Kurs 1 için 4 puan veriyor
INSERT INTO Yorum (yorum_id, ogrenci_id, kurs_id, yorum_metin, puan, yorum_tarihi) VALUES
(2, 2, 1, 'İçerik güzel ama biraz daha örnek olabilirdi.', 4, '2024-03-13');

-- Kursu tamamlayanlar için sertifika
INSERT INTO Sertifika (sertifika_id, ogrenci_id, kurs_id, verilis_tarihi, sertifika_kodu) VALUES
(1, 1, 1, '2024-03-20', 'CERT-SQL-ALI-0001'),
(2, 2, 2, '2024-03-21', 'CERT-WEB-AYSE-0001');

