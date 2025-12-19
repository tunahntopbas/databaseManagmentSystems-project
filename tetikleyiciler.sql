CREATE TRIGGER trg_kullanici_kayit_kontrol
BEFORE INSERT OR UPDATE ON Kullanici
FOR EACH ROW
EXECUTE FUNCTION kullanici_kayit_kontrol();

CREATE TRIGGER trg_yorum_kayit_kontrol
BEFORE INSERT ON Yorum
FOR EACH ROW
EXECUTE FUNCTION yorum_kayit_kontrol();

CREATE TRIGGER trg_yorum_kurs_puan
AFTER INSERT OR UPDATE OR DELETE ON Yorum
FOR EACH ROW
EXECUTE FUNCTION yorum_sonra_kurs_puani();

CREATE TRIGGER trg_odeme_kayit_durum
AFTER INSERT OR UPDATE ON Odeme
FOR EACH ROW
EXECUTE FUNCTION odeme_sonra_kayit_durumu();
