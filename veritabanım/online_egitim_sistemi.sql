--
-- PostgreSQL database dump
--

\restrict vXFf1cGeEwrTiYCYGwdee7J3QcGQf62wBiyk4nlZZG7SVxGW2x07aAWYz0n5x9p

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: egitmen_disjoint_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.egitmen_disjoint_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Ogrenci
    WHERE kullanici_id = NEW.kullanici_id
  ) THEN
    RAISE EXCEPTION
      'Bu kullanıcı zaten öğrenci. Aynı kullanıcı eğitmen olamaz.';
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.egitmen_disjoint_kontrol() OWNER TO postgres;

--
-- Name: kayit_durum_guncelle(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kayit_durum_guncelle(p_kayit_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    toplam_odeme NUMERIC;
    kurs_fiyat NUMERIC;
    mevcut_durum TEXT;
BEGIN
    SELECT durum INTO mevcut_durum
    FROM Kayit
    WHERE kayit_id = p_kayit_id;

    -- İPTAL ise dokunma
    IF mevcut_durum = 'iptal' THEN
        RETURN;
    END IF;

    SELECT COALESCE(SUM(tutar), 0) INTO toplam_odeme
    FROM Odeme
    WHERE kayit_id = p_kayit_id;

    SELECT k.fiyat INTO kurs_fiyat
    FROM Kurs k
    JOIN Kayit ka ON ka.kurs_id = k.kurs_id
    WHERE ka.kayit_id = p_kayit_id;

    IF toplam_odeme >= kurs_fiyat THEN
        UPDATE Kayit SET durum = 'tamamlandi'
        WHERE kayit_id = p_kayit_id;
    ELSE
        UPDATE Kayit SET durum = 'aktif'
        WHERE kayit_id = p_kayit_id;
    END IF;
END;
$$;


ALTER FUNCTION public.kayit_durum_guncelle(p_kayit_id integer) OWNER TO postgres;

--
-- Name: kullanici_kayit_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kullanici_kayit_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.email := LOWER(TRIM(NEW.email));
    NEW.ad    := TRIM(NEW.ad);
    NEW.soyad := TRIM(NEW.soyad);

    IF NEW.rol NOT IN ('ogrenci', 'egitmen', 'admin') THEN
        RAISE EXCEPTION 'Gecersiz rol: %', NEW.rol;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.kullanici_kayit_kontrol() OWNER TO postgres;

--
-- Name: kullanici_kayit_temizle_ve_rol_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kullanici_kayit_temizle_ve_rol_kontrol() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- 1) Temel metin temizliği
    UPDATE Kullanici
    SET email = LOWER(TRIM(email)),
        ad    = TRIM(ad),
        soyad = TRIM(soyad);

    -- 2) Rol alanı için basit kontrol
    IF EXISTS (
        SELECT 1
        FROM Kullanici
        WHERE rol IS NULL
           OR rol NOT IN ('ogrenci', 'egitmen', 'admin')
    ) THEN
        RAISE EXCEPTION 'Kullanici tablosunda gecersiz veya bos rol degeri var.';
    END IF;
END;
$$;


ALTER FUNCTION public.kullanici_kayit_temizle_ve_rol_kontrol() OWNER TO postgres;

--
-- Name: kurs_puan_guncelle(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kurs_puan_guncelle(p_kurs_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_ortalama DECIMAL(3,2);
    v_sayi     INTEGER;
BEGIN
    SELECT AVG(puan)::DECIMAL(3,2), COUNT(*)
    INTO v_ortalama, v_sayi
    FROM Yorum
    WHERE kurs_id = p_kurs_id;

    UPDATE Kurs
    SET ortalama_puan = CASE WHEN v_sayi = 0 THEN NULL ELSE v_ortalama END,
        yorum_sayisi  = v_sayi
    WHERE kurs_id = p_kurs_id;
END;
$$;


ALTER FUNCTION public.kurs_puan_guncelle(p_kurs_id integer) OWNER TO postgres;

--
-- Name: odeme_sonra_kayit_durumu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.odeme_sonra_kayit_durumu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM kayit_durum_guncelle(NEW.kayit_id);
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.odeme_sonra_kayit_durumu() OWNER TO postgres;

--
-- Name: ogrenci_disjoint_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ogrenci_disjoint_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Egitmen
    WHERE kullanici_id = NEW.kullanici_id
  ) THEN
    RAISE EXCEPTION
      'Bu kullanıcı zaten eğitmen. Aynı kullanıcı öğrenci olamaz.';
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.ogrenci_disjoint_kontrol() OWNER TO postgres;

--
-- Name: ogrenci_quiz_dogru_sayisi(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ogrenci_quiz_dogru_sayisi(p_ogrenci_id integer, p_quiz_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_dogru_sayisi INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_dogru_sayisi
    FROM Ogrenci_Cevap oc
    JOIN Soru s     ON s.soru_id = oc.soru_id
    JOIN Secenek se ON se.secenek_id = oc.secenek_id
    WHERE oc.ogrenci_id = p_ogrenci_id
      AND s.quiz_id     = p_quiz_id
      AND se.dogru_mu   = TRUE;

    RETURN COALESCE(v_dogru_sayisi, 0);
END;
$$;


ALTER FUNCTION public.ogrenci_quiz_dogru_sayisi(p_ogrenci_id integer, p_quiz_id integer) OWNER TO postgres;

--
-- Name: yorum_kayit_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.yorum_kayit_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_sayi INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_sayi
    FROM Kayit
    WHERE ogrenci_id = NEW.ogrenci_id
      AND kurs_id    = NEW.kurs_id;

    IF v_sayi = 0 THEN
        RAISE EXCEPTION 'Bu kursa kayıtlı olmayan öğrenci yorum yapamaz.';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.yorum_kayit_kontrol() OWNER TO postgres;

--
-- Name: yorum_sonra_kurs_puani(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.yorum_sonra_kurs_puani() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_kurs_id INTEGER;
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        v_kurs_id := NEW.kurs_id;
    ELSE
        v_kurs_id := OLD.kurs_id;
    END IF;

    PERFORM kurs_puan_guncelle(v_kurs_id);

    RETURN NULL;
END;
$$;


ALTER FUNCTION public.yorum_sonra_kurs_puani() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ders (
    ders_id integer NOT NULL,
    modul_id integer NOT NULL,
    baslik character varying(200) NOT NULL,
    aciklama text,
    video_url character varying(500),
    sure_dk integer,
    sira_no integer
);


ALTER TABLE public.ders OWNER TO postgres;

--
-- Name: ders_ders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ders_ders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ders_ders_id_seq OWNER TO postgres;

--
-- Name: ders_ders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ders_ders_id_seq OWNED BY public.ders.ders_id;


--
-- Name: egitmen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.egitmen (
    kullanici_id integer NOT NULL,
    unvan character varying(100),
    biyografi text
);


ALTER TABLE public.egitmen OWNER TO postgres;

--
-- Name: icerik_dosya; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.icerik_dosya (
    dosya_id integer NOT NULL,
    ders_id integer NOT NULL,
    dosya_adi character varying(255) NOT NULL,
    dosya_turu character varying(50),
    dosya_yolu character varying(500) NOT NULL
);


ALTER TABLE public.icerik_dosya OWNER TO postgres;

--
-- Name: icerik_dosya_dosya_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.icerik_dosya_dosya_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.icerik_dosya_dosya_id_seq OWNER TO postgres;

--
-- Name: icerik_dosya_dosya_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.icerik_dosya_dosya_id_seq OWNED BY public.icerik_dosya.dosya_id;


--
-- Name: kategori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kategori (
    kategori_id integer NOT NULL,
    ad character varying(100) NOT NULL,
    aciklama text
);


ALTER TABLE public.kategori OWNER TO postgres;

--
-- Name: kategori_kategori_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kategori_kategori_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kategori_kategori_id_seq OWNER TO postgres;

--
-- Name: kategori_kategori_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kategori_kategori_id_seq OWNED BY public.kategori.kategori_id;


--
-- Name: kayit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kayit (
    kayit_id integer NOT NULL,
    ogrenci_id integer NOT NULL,
    kurs_id integer NOT NULL,
    kayit_tarihi date DEFAULT CURRENT_DATE NOT NULL,
    durum character varying(20) DEFAULT 'aktif'::character varying NOT NULL,
    CONSTRAINT chk_kayit_durum CHECK (((durum)::text = ANY ((ARRAY['aktif'::character varying, 'iptal'::character varying, 'tamamlandi'::character varying])::text[])))
);


ALTER TABLE public.kayit OWNER TO postgres;

--
-- Name: kayit_kayit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kayit_kayit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kayit_kayit_id_seq OWNER TO postgres;

--
-- Name: kayit_kayit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kayit_kayit_id_seq OWNED BY public.kayit.kayit_id;


--
-- Name: kullanici; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kullanici (
    kullanici_id integer NOT NULL,
    ad character varying(100) NOT NULL,
    soyad character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    sifre character varying(255) NOT NULL,
    rol character varying(20) NOT NULL,
    kayit_tarihi date DEFAULT CURRENT_DATE NOT NULL,
    aktif boolean DEFAULT true NOT NULL,
    CONSTRAINT chk_kullanici_rol CHECK (((rol)::text = ANY ((ARRAY['ogrenci'::character varying, 'egitmen'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.kullanici OWNER TO postgres;

--
-- Name: kullanici_kullanici_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kullanici_kullanici_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kullanici_kullanici_id_seq OWNER TO postgres;

--
-- Name: kullanici_kullanici_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kullanici_kullanici_id_seq OWNED BY public.kullanici.kullanici_id;


--
-- Name: kurs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kurs (
    kurs_id integer NOT NULL,
    baslik character varying(200) NOT NULL,
    aciklama text,
    seviye character varying(50),
    fiyat numeric(10,2),
    yayinda boolean DEFAULT true NOT NULL,
    olusturma_tarihi date DEFAULT CURRENT_DATE NOT NULL,
    ortalama_puan numeric(3,2),
    yorum_sayisi integer DEFAULT 0,
    CONSTRAINT chk_kurs_seviye CHECK (((seviye IS NULL) OR ((seviye)::text = ANY ((ARRAY['Baslangic'::character varying, 'Orta'::character varying, 'Ileri'::character varying])::text[]))))
);


ALTER TABLE public.kurs OWNER TO postgres;

--
-- Name: kurs_egitmen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kurs_egitmen (
    kurs_id integer NOT NULL,
    egitmen_id integer NOT NULL
);


ALTER TABLE public.kurs_egitmen OWNER TO postgres;

--
-- Name: kurs_kategori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kurs_kategori (
    kurs_id integer NOT NULL,
    kategori_id integer NOT NULL
);


ALTER TABLE public.kurs_kategori OWNER TO postgres;

--
-- Name: kurs_kurs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kurs_kurs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kurs_kurs_id_seq OWNER TO postgres;

--
-- Name: kurs_kurs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kurs_kurs_id_seq OWNED BY public.kurs.kurs_id;


--
-- Name: modul; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modul (
    modul_id integer NOT NULL,
    kurs_id integer NOT NULL,
    baslik character varying(200) NOT NULL,
    sira_no integer
);


ALTER TABLE public.modul OWNER TO postgres;

--
-- Name: modul_modul_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.modul_modul_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.modul_modul_id_seq OWNER TO postgres;

--
-- Name: modul_modul_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.modul_modul_id_seq OWNED BY public.modul.modul_id;


--
-- Name: odeme; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.odeme (
    odeme_id integer NOT NULL,
    kayit_id integer NOT NULL,
    tutar numeric(10,2) NOT NULL,
    odeme_tarihi date DEFAULT CURRENT_DATE NOT NULL,
    odeme_yontemi character varying(50),
    durum character varying(20)
);


ALTER TABLE public.odeme OWNER TO postgres;

--
-- Name: odeme_odeme_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.odeme_odeme_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.odeme_odeme_id_seq OWNER TO postgres;

--
-- Name: odeme_odeme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.odeme_odeme_id_seq OWNED BY public.odeme.odeme_id;


--
-- Name: ogrenci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ogrenci (
    kullanici_id integer NOT NULL,
    ogrenci_no character varying(50),
    dogum_tarihi date
);


ALTER TABLE public.ogrenci OWNER TO postgres;

--
-- Name: ogrenci_cevap; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ogrenci_cevap (
    cevap_id integer NOT NULL,
    ogrenci_id integer NOT NULL,
    soru_id integer NOT NULL,
    secenek_id integer,
    verilen_cevap_metin text,
    cevap_tarihi date DEFAULT CURRENT_DATE NOT NULL
);


ALTER TABLE public.ogrenci_cevap OWNER TO postgres;

--
-- Name: ogrenci_cevap_cevap_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ogrenci_cevap_cevap_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ogrenci_cevap_cevap_id_seq OWNER TO postgres;

--
-- Name: ogrenci_cevap_cevap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ogrenci_cevap_cevap_id_seq OWNED BY public.ogrenci_cevap.cevap_id;


--
-- Name: quiz; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quiz (
    quiz_id integer NOT NULL,
    kurs_id integer NOT NULL,
    baslik character varying(200) NOT NULL,
    aciklama text,
    yayin_tarihi date
);


ALTER TABLE public.quiz OWNER TO postgres;

--
-- Name: quiz_quiz_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quiz_quiz_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quiz_quiz_id_seq OWNER TO postgres;

--
-- Name: quiz_quiz_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quiz_quiz_id_seq OWNED BY public.quiz.quiz_id;


--
-- Name: secenek; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.secenek (
    secenek_id integer NOT NULL,
    soru_id integer NOT NULL,
    metin text NOT NULL,
    dogru_mu boolean DEFAULT false NOT NULL
);


ALTER TABLE public.secenek OWNER TO postgres;

--
-- Name: secenek_secenek_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.secenek_secenek_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.secenek_secenek_id_seq OWNER TO postgres;

--
-- Name: secenek_secenek_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.secenek_secenek_id_seq OWNED BY public.secenek.secenek_id;


--
-- Name: sertifika; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sertifika (
    sertifika_id integer NOT NULL,
    ogrenci_id integer NOT NULL,
    kurs_id integer NOT NULL,
    verilis_tarihi date DEFAULT CURRENT_DATE NOT NULL,
    sertifika_kodu character varying(100) NOT NULL
);


ALTER TABLE public.sertifika OWNER TO postgres;

--
-- Name: sertifika_sertifika_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sertifika_sertifika_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sertifika_sertifika_id_seq OWNER TO postgres;

--
-- Name: sertifika_sertifika_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sertifika_sertifika_id_seq OWNED BY public.sertifika.sertifika_id;


--
-- Name: soru; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.soru (
    soru_id integer NOT NULL,
    quiz_id integer NOT NULL,
    metin text NOT NULL,
    soru_tipi character varying(50),
    zorluk_derecesi integer
);


ALTER TABLE public.soru OWNER TO postgres;

--
-- Name: soru_soru_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.soru_soru_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.soru_soru_id_seq OWNER TO postgres;

--
-- Name: soru_soru_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.soru_soru_id_seq OWNED BY public.soru.soru_id;


--
-- Name: yorum; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yorum (
    yorum_id integer NOT NULL,
    ogrenci_id integer NOT NULL,
    kurs_id integer NOT NULL,
    yorum_metin text,
    puan integer NOT NULL,
    yorum_tarihi date DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT chk_yorum_puan CHECK (((puan >= 1) AND (puan <= 5)))
);


ALTER TABLE public.yorum OWNER TO postgres;

--
-- Name: yorum_yorum_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.yorum_yorum_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.yorum_yorum_id_seq OWNER TO postgres;

--
-- Name: yorum_yorum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.yorum_yorum_id_seq OWNED BY public.yorum.yorum_id;


--
-- Name: ders ders_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ders ALTER COLUMN ders_id SET DEFAULT nextval('public.ders_ders_id_seq'::regclass);


--
-- Name: icerik_dosya dosya_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.icerik_dosya ALTER COLUMN dosya_id SET DEFAULT nextval('public.icerik_dosya_dosya_id_seq'::regclass);


--
-- Name: kategori kategori_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori ALTER COLUMN kategori_id SET DEFAULT nextval('public.kategori_kategori_id_seq'::regclass);


--
-- Name: kayit kayit_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kayit ALTER COLUMN kayit_id SET DEFAULT nextval('public.kayit_kayit_id_seq'::regclass);


--
-- Name: kullanici kullanici_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici ALTER COLUMN kullanici_id SET DEFAULT nextval('public.kullanici_kullanici_id_seq'::regclass);


--
-- Name: kurs kurs_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kurs ALTER COLUMN kurs_id SET DEFAULT nextval('public.kurs_kurs_id_seq'::regclass);


--
-- Name: modul modul_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modul ALTER COLUMN modul_id SET DEFAULT nextval('public.modul_modul_id_seq'::regclass);


--
-- Name: odeme odeme_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.odeme ALTER COLUMN odeme_id SET DEFAULT nextval('public.odeme_odeme_id_seq'::regclass);


--
-- Name: ogrenci_cevap cevap_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ogrenci_cevap ALTER COLUMN cevap_id SET DEFAULT nextval('public.ogrenci_cevap_cevap_id_seq'::regclass);


--
-- Name: quiz quiz_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz ALTER COLUMN quiz_id SET DEFAULT nextval('public.quiz_quiz_id_seq'::regclass);


--
-- Name: secenek secenek_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.secenek ALTER COLUMN secenek_id SET DEFAULT nextval('public.secenek_secenek_id_seq'::regclass);


--
-- Name: sertifika sertifika_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sertifika ALTER COLUMN sertifika_id SET DEFAULT nextval('public.sertifika_sertifika_id_seq'::regclass);


--
-- Name: soru soru_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soru ALTER COLUMN soru_id SET DEFAULT nextval('public.soru_soru_id_seq'::regclass);


--
-- Name: yorum yorum_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yorum ALTER COLUMN yorum_id SET DEFAULT nextval('public.yorum_yorum_id_seq'::regclass);


--
-- Data for Name: ders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ders (ders_id, modul_id, baslik, aciklama, video_url, sure_dk, sira_no) FROM stdin;
1	1	Veritabanı Nedir?	Veritabanı kavramına giriş.	https://video.example.com/1	25	1
2	2	SELECT ile Veri Okuma	Temel SELECT sorguları.	https://video.example.com/2	35	1
3	3	HTML Temelleri	Basit HTML etiketleri.	https://video.example.com/3	30	1
\.


--
-- Data for Name: egitmen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.egitmen (kullanici_id, unvan, biyografi) FROM stdin;
3	Dr.	Veri tabanları ve SQL konusunda uzman.
4	Öğr. Gör.	Web geliştirme ve front-end alanında deneyimli.
\.


--
-- Data for Name: icerik_dosya; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.icerik_dosya (dosya_id, ders_id, dosya_adi, dosya_turu, dosya_yolu) FROM stdin;
1	1	veritabani_giris.pdf	pdf	/dosyalar/veritabani_giris.pdf
2	2	select_ornekleri.sql	sql	/dosyalar/select_ornekleri.sql
\.


--
-- Data for Name: kategori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kategori (kategori_id, ad, aciklama) FROM stdin;
1	Programlama	Genel amaçlı programlama dilleri ve yazılım geliştirme.
2	Veri Tabanı	İlişkisel veritabanları, SQL ve veri modelleme.
3	Web Geliştirme	Ön yüz ve arka yüz web teknolojileri.
4	Mobil Geliştirme	Android ve iOS için mobil uygulama geliştirme kursları.
\.


--
-- Data for Name: kayit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kayit (kayit_id, ogrenci_id, kurs_id, kayit_tarihi, durum) FROM stdin;
1	1	1	2024-03-01	tamamlandi
2	2	1	2024-03-05	aktif
3	2	2	2024-03-06	tamamlandi
\.


--
-- Data for Name: kullanici; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kullanici (kullanici_id, ad, soyad, email, sifre, rol, kayit_tarihi, aktif) FROM stdin;
1	Ali	Yılmaz	ali.yilmaz@example.com	123456	ogrenci	2024-01-10	t
2	Ayşe	Demir	ayse.demir@example.com	123456	ogrenci	2024-02-05	t
3	Mehmet	Kara	mehmet.kara@example.com	123456	egitmen	2024-01-01	t
4	Zeynep	Şahin	zeynep.sahin@example.com	123456	egitmen	2024-01-15	t
5	Admin	User	admin@example.com	123456	admin	2024-01-01	t
\.


--
-- Data for Name: kurs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kurs (kurs_id, baslik, aciklama, seviye, fiyat, yayinda, olusturma_tarihi, ortalama_puan, yorum_sayisi) FROM stdin;
2	Web Programlamaya Giriş	HTML, CSS ve temel JavaScript ile web sayfası geliştirme.	Baslangic	300.00	t	2024-02-10	\N	0
1	Deneme Kurs	İlişkisel modeller, temel SQL sorguları ve veritabanı tasarımı.	Baslangic	900.00	t	2024-01-20	4.50	2
\.


--
-- Data for Name: kurs_egitmen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kurs_egitmen (kurs_id, egitmen_id) FROM stdin;
1	3
1	4
2	4
\.


--
-- Data for Name: kurs_kategori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kurs_kategori (kurs_id, kategori_id) FROM stdin;
1	1
1	2
2	1
2	3
\.


--
-- Data for Name: modul; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modul (modul_id, kurs_id, baslik, sira_no) FROM stdin;
1	1	Giriş ve Temel Kavramlar	1
2	1	Temel SQL Komutları	2
3	2	Web Temelleri	1
\.


--
-- Data for Name: odeme; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.odeme (odeme_id, kayit_id, tutar, odeme_tarihi, odeme_yontemi, durum) FROM stdin;
1	1	500.00	2024-03-02	kart	tamamlandi
2	2	250.00	2024-03-06	kart	beklemede
3	3	300.00	2024-03-07	kart	tamamlandi
\.


--
-- Data for Name: ogrenci; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ogrenci (kullanici_id, ogrenci_no, dogum_tarihi) FROM stdin;
1	2023001	2004-03-12
2	2023002	2003-11-05
\.


--
-- Data for Name: ogrenci_cevap; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ogrenci_cevap (cevap_id, ogrenci_id, soru_id, secenek_id, verilen_cevap_metin, cevap_tarihi) FROM stdin;
1	1	1	3	\N	2024-03-11
2	1	2	5	\N	2024-03-11
3	2	1	2	\N	2024-03-11
4	2	2	5	\N	2024-03-11
\.


--
-- Data for Name: quiz; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quiz (quiz_id, kurs_id, baslik, aciklama, yayin_tarihi) FROM stdin;
1	1	SQL Temel Quiz	Temel SQL bilgisi ölçme sınavı.	2024-03-10
\.


--
-- Data for Name: secenek; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.secenek (secenek_id, soru_id, metin, dogru_mu) FROM stdin;
1	1	Veri eklemek için	f
2	1	Veri silmek için	f
3	1	Veri sorgulamak için	t
4	2	Sorgu sonucunu sıralamak için	f
5	2	Belirli şartlara göre filtreleme yapmak için	t
6	2	Tablo oluşturmak için	f
\.


--
-- Data for Name: sertifika; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sertifika (sertifika_id, ogrenci_id, kurs_id, verilis_tarihi, sertifika_kodu) FROM stdin;
1	1	1	2024-03-20	CERT-SQL-ALI-0001
2	2	2	2024-03-21	CERT-WEB-AYSE-0001
\.


--
-- Data for Name: soru; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.soru (soru_id, quiz_id, metin, soru_tipi, zorluk_derecesi) FROM stdin;
1	1	SELECT sorgusu hangi amaçla kullanılır?	coktan_secmeli	1
2	1	WHERE ifadesinin görevi nedir?	coktan_secmeli	2
\.


--
-- Data for Name: yorum; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.yorum (yorum_id, ogrenci_id, kurs_id, yorum_metin, puan, yorum_tarihi) FROM stdin;
1	1	1	Kurs çok açıklayıcı ve anlaşılırdı.	5	2024-03-12
2	2	1	İçerik güzel ama biraz daha örnek olabilirdi.	4	2024-03-13
\.


--
-- Name: ders_ders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ders_ders_id_seq', 1, false);


--
-- Name: icerik_dosya_dosya_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.icerik_dosya_dosya_id_seq', 1, false);


--
-- Name: kategori_kategori_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kategori_kategori_id_seq', 4, true);


--
-- Name: kayit_kayit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kayit_kayit_id_seq', 1, false);


--
-- Name: kullanici_kullanici_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kullanici_kullanici_id_seq', 1, false);


--
-- Name: kurs_kurs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kurs_kurs_id_seq', 7, true);


--
-- Name: modul_modul_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.modul_modul_id_seq', 1, false);


--
-- Name: odeme_odeme_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.odeme_odeme_id_seq', 1, false);


--
-- Name: ogrenci_cevap_cevap_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ogrenci_cevap_cevap_id_seq', 1, false);


--
-- Name: quiz_quiz_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quiz_quiz_id_seq', 1, false);


--
-- Name: secenek_secenek_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.secenek_secenek_id_seq', 1, false);


--
-- Name: sertifika_sertifika_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sertifika_sertifika_id_seq', 1, false);


--
-- Name: soru_soru_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.soru_soru_id_seq', 1, false);


--
-- Name: yorum_yorum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.yorum_yorum_id_seq', 1, false);


--
-- Name: ders ders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ders
    ADD CONSTRAINT ders_pkey PRIMARY KEY (ders_id);


--
-- Name: egitmen egitmen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.egitmen
    ADD CONSTRAINT egitmen_pkey PRIMARY KEY (kullanici_id);


--
-- Name: icerik_dosya icerik_dosya_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.icerik_dosya
    ADD CONSTRAINT icerik_dosya_pkey PRIMARY KEY (dosya_id);


--
-- Name: kategori kategori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_pkey PRIMARY KEY (kategori_id);


--
-- Name: kayit kayit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kayit
    ADD CONSTRAINT kayit_pkey PRIMARY KEY (kayit_id);


--
-- Name: kullanici kullanici_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici
    ADD CONSTRAINT kullanici_email_key UNIQUE (email);


--
-- Name: kullanici kullanici_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici
    ADD CONSTRAINT kullanici_pkey PRIMARY KEY (kullanici_id);


--
-- Name: kurs_egitmen kurs_egitmen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kurs_egitmen
    ADD CONSTRAINT kurs_egitmen_pkey PRIMARY KEY (kurs_id, egitmen_id);


--
-- Name: kurs_kategori kurs_kategori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kurs_kategori
    ADD CONSTRAINT kurs_kategori_pkey PRIMARY KEY (kurs_id, kategori_id);


--
-- Name: kurs kurs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kurs
    ADD CONSTRAINT kurs_pkey PRIMARY KEY (kurs_id);


--
-- Name: modul modul_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modul
    ADD CONSTRAINT modul_pkey PRIMARY KEY (modul_id);


--
-- Name: odeme odeme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.odeme
    ADD CONSTRAINT odeme_pkey PRIMARY KEY (odeme_id);


--
-- Name: ogrenci_cevap ogrenci_cevap_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ogrenci_cevap
    ADD CONSTRAINT ogrenci_cevap_pkey PRIMARY KEY (cevap_id);


--
-- Name: ogrenci ogrenci_ogrenci_no_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ogrenci
    ADD CONSTRAINT ogrenci_ogrenci_no_key UNIQUE (ogrenci_no);


--
-- Name: ogrenci ogrenci_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ogrenci
    ADD CONSTRAINT ogrenci_pkey PRIMARY KEY (kullanici_id);


--
-- Name: quiz quiz_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz
    ADD CONSTRAINT quiz_pkey PRIMARY KEY (quiz_id);


--
-- Name: secenek secenek_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.secenek
    ADD CONSTRAINT secenek_pkey PRIMARY KEY (secenek_id);


--
-- Name: sertifika sertifika_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sertifika
    ADD CONSTRAINT sertifika_pkey PRIMARY KEY (sertifika_id);


--
-- Name: sertifika sertifika_sertifika_kodu_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sertifika
    ADD CONSTRAINT sertifika_sertifika_kodu_key UNIQUE (sertifika_kodu);


--
-- Name: soru soru_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soru
    ADD CONSTRAINT soru_pkey PRIMARY KEY (soru_id);


--
-- Name: kayit uq_kayit_ogrenci_kurs; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kayit
    ADD CONSTRAINT uq_kayit_ogrenci_kurs UNIQUE (ogrenci_id, kurs_id);


--
-- Name: ogrenci_cevap uq_ogrenci_soru; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ogrenci_cevap
    ADD CONSTRAINT uq_ogrenci_soru UNIQUE (ogrenci_id, soru_id);


--
-- Name: yorum yorum_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yorum
    ADD CONSTRAINT yorum_pkey PRIMARY KEY (yorum_id);


--
-- Name: egitmen trg_egitmen_disjoint; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_egitmen_disjoint BEFORE INSERT OR UPDATE ON public.egitmen FOR EACH ROW EXECUTE FUNCTION public.egitmen_disjoint_kontrol();


--
-- Name: kullanici trg_kullanici_kayit_kontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_kullanici_kayit_kontrol BEFORE INSERT OR UPDATE ON public.kullanici FOR EACH ROW EXECUTE FUNCTION public.kullanici_kayit_kontrol();


--
-- Name: odeme trg_odeme_kayit_durum; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_odeme_kayit_durum AFTER INSERT OR UPDATE ON public.odeme FOR EACH ROW EXECUTE FUNCTION public.odeme_sonra_kayit_durumu();


--
-- Name: ogrenci trg_ogrenci_disjoint; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_ogrenci_disjoint BEFORE INSERT OR UPDATE ON public.ogrenci FOR EACH ROW EXECUTE FUNCTION public.ogrenci_disjoint_kontrol();


--
-- Name: yorum trg_yorum_kayit_kontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_yorum_kayit_kontrol BEFORE INSERT ON public.yorum FOR EACH ROW EXECUTE FUNCTION public.yorum_kayit_kontrol();


--
-- Name: yorum trg_yorum_kurs_puan; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_yorum_kurs_puan AFTER INSERT OR DELETE OR UPDATE ON public.yorum FOR EACH ROW EXECUTE FUNCTION public.yorum_sonra_kurs_puani();


--
-- Name: ders fk_ders_modul; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ders
    ADD CONSTRAINT fk_ders_modul FOREIGN KEY (modul_id) REFERENCES public.modul(modul_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: egitmen fk_egitmen_kullanici; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.egitmen
    ADD CONSTRAINT fk_egitmen_kullanici FOREIGN KEY (kullanici_id) REFERENCES public.kullanici(kullanici_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: icerik_dosya fk_icerik_dosya_ders; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.icerik_dosya
    ADD CONSTRAINT fk_icerik_dosya_ders FOREIGN KEY (ders_id) REFERENCES public.ders(ders_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kayit fk_kayit_kurs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kayit
    ADD CONSTRAINT fk_kayit_kurs FOREIGN KEY (kurs_id) REFERENCES public.kurs(kurs_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kayit fk_kayit_ogrenci; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kayit
    ADD CONSTRAINT fk_kayit_ogrenci FOREIGN KEY (ogrenci_id) REFERENCES public.ogrenci(kullanici_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kurs_egitmen fk_kursegitmen_egitmen; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kurs_egitmen
    ADD CONSTRAINT fk_kursegitmen_egitmen FOREIGN KEY (egitmen_id) REFERENCES public.egitmen(kullanici_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kurs_egitmen fk_kursegitmen_kurs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kurs_egitmen
    ADD CONSTRAINT fk_kursegitmen_kurs FOREIGN KEY (kurs_id) REFERENCES public.kurs(kurs_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kurs_kategori fk_kurskategori_kategori; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kurs_kategori
    ADD CONSTRAINT fk_kurskategori_kategori FOREIGN KEY (kategori_id) REFERENCES public.kategori(kategori_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kurs_kategori fk_kurskategori_kurs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kurs_kategori
    ADD CONSTRAINT fk_kurskategori_kurs FOREIGN KEY (kurs_id) REFERENCES public.kurs(kurs_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: modul fk_modul_kurs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modul
    ADD CONSTRAINT fk_modul_kurs FOREIGN KEY (kurs_id) REFERENCES public.kurs(kurs_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: odeme fk_odeme_kayit; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.odeme
    ADD CONSTRAINT fk_odeme_kayit FOREIGN KEY (kayit_id) REFERENCES public.kayit(kayit_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ogrenci_cevap fk_ogrcevap_ogrenci; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ogrenci_cevap
    ADD CONSTRAINT fk_ogrcevap_ogrenci FOREIGN KEY (ogrenci_id) REFERENCES public.ogrenci(kullanici_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ogrenci_cevap fk_ogrcevap_secenek; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ogrenci_cevap
    ADD CONSTRAINT fk_ogrcevap_secenek FOREIGN KEY (secenek_id) REFERENCES public.secenek(secenek_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ogrenci_cevap fk_ogrcevap_soru; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ogrenci_cevap
    ADD CONSTRAINT fk_ogrcevap_soru FOREIGN KEY (soru_id) REFERENCES public.soru(soru_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ogrenci fk_ogrenci_kullanici; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ogrenci
    ADD CONSTRAINT fk_ogrenci_kullanici FOREIGN KEY (kullanici_id) REFERENCES public.kullanici(kullanici_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: quiz fk_quiz_kurs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz
    ADD CONSTRAINT fk_quiz_kurs FOREIGN KEY (kurs_id) REFERENCES public.kurs(kurs_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: secenek fk_secenek_soru; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.secenek
    ADD CONSTRAINT fk_secenek_soru FOREIGN KEY (soru_id) REFERENCES public.soru(soru_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sertifika fk_sertifika_kurs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sertifika
    ADD CONSTRAINT fk_sertifika_kurs FOREIGN KEY (kurs_id) REFERENCES public.kurs(kurs_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sertifika fk_sertifika_ogrenci; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sertifika
    ADD CONSTRAINT fk_sertifika_ogrenci FOREIGN KEY (ogrenci_id) REFERENCES public.ogrenci(kullanici_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: soru fk_soru_quiz; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soru
    ADD CONSTRAINT fk_soru_quiz FOREIGN KEY (quiz_id) REFERENCES public.quiz(quiz_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: yorum fk_yorum_kurs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yorum
    ADD CONSTRAINT fk_yorum_kurs FOREIGN KEY (kurs_id) REFERENCES public.kurs(kurs_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: yorum fk_yorum_ogrenci; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yorum
    ADD CONSTRAINT fk_yorum_ogrenci FOREIGN KEY (ogrenci_id) REFERENCES public.ogrenci(kullanici_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict vXFf1cGeEwrTiYCYGwdee7J3QcGQf62wBiyk4nlZZG7SVxGW2x07aAWYz0n5x9p

