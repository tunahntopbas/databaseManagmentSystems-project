CREATE TABLE Kullanici (
    kullanici_id    SERIAL PRIMARY KEY,
    ad              VARCHAR(100) NOT NULL,
    soyad           VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    sifre           VARCHAR(255) NOT NULL,
    rol             VARCHAR(20)  NOT NULL,     -- 'ogrenci', 'egitmen', 'admin' vb.
    kayit_tarihi    DATE         NOT NULL DEFAULT CURRENT_DATE,
    aktif           BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_kullanici_rol
        CHECK (rol IN ('ogrenci', 'egitmen', 'admin'))
);

CREATE TABLE Ogrenci (
    kullanici_id    INTEGER PRIMARY KEY,
    ogrenci_no      VARCHAR(50) UNIQUE,
    dogum_tarihi    DATE,
    CONSTRAINT fk_ogrenci_kullanici
        FOREIGN KEY (kullanici_id)
        REFERENCES Kullanici(kullanici_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Egitmen (
    kullanici_id    INTEGER PRIMARY KEY,
    unvan           VARCHAR(100),
    biyografi       TEXT,
    CONSTRAINT fk_egitmen_kullanici
        FOREIGN KEY (kullanici_id)
        REFERENCES Kullanici(kullanici_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Kategori (
    kategori_id     SERIAL PRIMARY KEY,
    ad              VARCHAR(100) NOT NULL,
    aciklama        TEXT
);

CREATE TABLE Kurs (
    kurs_id         SERIAL PRIMARY KEY,
    baslik          VARCHAR(200) NOT NULL,
    aciklama        TEXT,
    seviye          VARCHAR(50),         -- 'Baslangic', 'Orta', 'Ileri' vb.
    fiyat           DECIMAL(10,2),
    yayinda         BOOLEAN      NOT NULL DEFAULT TRUE,
    olusturma_tarihi DATE        NOT NULL DEFAULT CURRENT_DATE,
    ortalama_puan   DECIMAL(3,2),
    yorum_sayisi    INTEGER      DEFAULT 0,
    CONSTRAINT chk_kurs_seviye
        CHECK (seviye IS NULL OR seviye IN ('Baslangic', 'Orta', 'Ileri'))
);

CREATE TABLE Kurs_Kategori (
    kurs_id         INTEGER NOT NULL,
    kategori_id     INTEGER NOT NULL,
    PRIMARY KEY (kurs_id, kategori_id),
    CONSTRAINT fk_kurskategori_kurs
        FOREIGN KEY (kurs_id)
        REFERENCES Kurs(kurs_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_kurskategori_kategori
        FOREIGN KEY (kategori_id)
        REFERENCES Kategori(kategori_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Kurs_Egitmen (
    kurs_id         INTEGER NOT NULL,
    egitmen_id      INTEGER NOT NULL,
    PRIMARY KEY (kurs_id, egitmen_id),
    CONSTRAINT fk_kursegitmen_kurs
        FOREIGN KEY (kurs_id)
        REFERENCES Kurs(kurs_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_kursegitmen_egitmen
        FOREIGN KEY (egitmen_id)
        REFERENCES Egitmen(kullanici_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Modul (
    modul_id        SERIAL PRIMARY KEY,
    kurs_id         INTEGER NOT NULL,
    baslik          VARCHAR(200) NOT NULL,
    sira_no         INTEGER,
    CONSTRAINT fk_modul_kurs
        FOREIGN KEY (kurs_id)
        REFERENCES Kurs(kurs_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Ders (
    ders_id         SERIAL PRIMARY KEY,
    modul_id        INTEGER NOT NULL,
    baslik          VARCHAR(200) NOT NULL,
    aciklama        TEXT,
    video_url       VARCHAR(500),
    sure_dk         INTEGER,
    sira_no         INTEGER,
    CONSTRAINT fk_ders_modul
        FOREIGN KEY (modul_id)
        REFERENCES Modul(modul_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Icerik_Dosya (
    dosya_id        SERIAL PRIMARY KEY,
    ders_id         INTEGER NOT NULL,
    dosya_adi       VARCHAR(255) NOT NULL,
    dosya_turu      VARCHAR(50),
    dosya_yolu      VARCHAR(500) NOT NULL,
    CONSTRAINT fk_icerik_dosya_ders
        FOREIGN KEY (ders_id)
        REFERENCES Ders(ders_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Kayit (
    kayit_id        SERIAL PRIMARY KEY,
    ogrenci_id      INTEGER NOT NULL,
    kurs_id         INTEGER NOT NULL,
    kayit_tarihi    DATE    NOT NULL DEFAULT CURRENT_DATE,
    durum           VARCHAR(20) NOT NULL DEFAULT 'aktif',
    CONSTRAINT fk_kayit_ogrenci
        FOREIGN KEY (ogrenci_id)
        REFERENCES Ogrenci(kullanici_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_kayit_kurs
        FOREIGN KEY (kurs_id)
        REFERENCES Kurs(kurs_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT uq_kayit_ogrenci_kurs
        UNIQUE (ogrenci_id, kurs_id),
    CONSTRAINT chk_kayit_durum
        CHECK (durum IN ('aktif', 'iptal', 'tamamlandi'))
);

CREATE TABLE Odeme (
    odeme_id        SERIAL PRIMARY KEY,
    kayit_id        INTEGER NOT NULL,
    tutar           DECIMAL(10,2) NOT NULL,
    odeme_tarihi    DATE          NOT NULL DEFAULT CURRENT_DATE,
    odeme_yontemi   VARCHAR(50),
    durum           VARCHAR(20),
    CONSTRAINT fk_odeme_kayit
        FOREIGN KEY (kayit_id)
        REFERENCES Kayit(kayit_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Sertifika (
    sertifika_id    SERIAL PRIMARY KEY,
    ogrenci_id      INTEGER NOT NULL,
    kurs_id         INTEGER NOT NULL,
    verilis_tarihi  DATE    NOT NULL DEFAULT CURRENT_DATE,
    sertifika_kodu  VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT fk_sertifika_ogrenci
        FOREIGN KEY (ogrenci_id)
        REFERENCES Ogrenci(kullanici_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_sertifika_kurs
        FOREIGN KEY (kurs_id)
        REFERENCES Kurs(kurs_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Yorum (
    yorum_id        SERIAL PRIMARY KEY,
    ogrenci_id      INTEGER NOT NULL,
    kurs_id         INTEGER NOT NULL,
    yorum_metin     TEXT,
    puan            INTEGER NOT NULL,
    yorum_tarihi    DATE    NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_yorum_ogrenci
        FOREIGN KEY (ogrenci_id)
        REFERENCES Ogrenci(kullanici_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_yorum_kurs
        FOREIGN KEY (kurs_id)
        REFERENCES Kurs(kurs_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_yorum_puan
        CHECK (puan BETWEEN 1 AND 5)
);

CREATE TABLE Quiz (
    quiz_id         SERIAL PRIMARY KEY,
    kurs_id         INTEGER NOT NULL,
    baslik          VARCHAR(200) NOT NULL,
    aciklama        TEXT,
    yayin_tarihi    DATE,
    CONSTRAINT fk_quiz_kurs
        FOREIGN KEY (kurs_id)
        REFERENCES Kurs(kurs_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Soru (
    soru_id         SERIAL PRIMARY KEY,
    quiz_id         INTEGER NOT NULL,
    metin           TEXT    NOT NULL,
    soru_tipi       VARCHAR(50),
    zorluk_derecesi INTEGER,
    CONSTRAINT fk_soru_quiz
        FOREIGN KEY (quiz_id)
        REFERENCES Quiz(quiz_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Secenek (
    secenek_id      SERIAL PRIMARY KEY,
    soru_id         INTEGER NOT NULL,
    metin           TEXT    NOT NULL,
    dogru_mu        BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_secenek_soru
        FOREIGN KEY (soru_id)
        REFERENCES Soru(soru_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Ogrenci_Cevap (
    cevap_id            SERIAL PRIMARY KEY,
    ogrenci_id          INTEGER NOT NULL,
    soru_id             INTEGER NOT NULL,
    secenek_id          INTEGER,
    verilen_cevap_metin TEXT,
    cevap_tarihi        DATE    NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_ogrcevap_ogrenci
        FOREIGN KEY (ogrenci_id)
        REFERENCES Ogrenci(kullanici_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ogrcevap_soru
        FOREIGN KEY (soru_id)
        REFERENCES Soru(soru_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ogrcevap_secenek
        FOREIGN KEY (secenek_id)
        REFERENCES Secenek(secenek_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT uq_ogrenci_soru
        UNIQUE (ogrenci_id, soru_id)
);


