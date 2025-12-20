using System;
using System.Data;
using System.Windows.Forms;
using Npgsql;

namespace online_egitim_sistemi
{
    public partial class Form1 : Form
    {
        private readonly string _connString =
            "Host=localhost;Port=5432;Database=online_egitim_sistemi;Username=postgres;Password=123456;";

        public Form1()
        {
            InitializeComponent();
        }

        // Ortak grid doldurma (parametresiz)
        private void GridDoldur(string sql)
        {
            try
            {
                using (var conn = new NpgsqlConnection(_connString))
                {
                    conn.Open();

                    using (var cmd = new NpgsqlCommand(sql, conn))
                    using (var da = new NpgsqlDataAdapter(cmd))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);
                        dgvKurslar.DataSource = dt;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata:\n" + ex.Message);
            }
        }

        // Ortak grid doldurma (tek parametreli) -> Arama için
        private void GridDoldur(string sql, string aranan)
        {
            try
            {
                using (var conn = new NpgsqlConnection(_connString))
                {
                    conn.Open();

                    using (var cmd = new NpgsqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@aranan", aranan);

                        using (var da = new NpgsqlDataAdapter(cmd))
                        {
                            var dt = new DataTable();
                            da.Fill(dt);
                            dgvKurslar.DataSource = dt;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata:\n" + ex.Message);
            }
        }

        // Kursları yükle (listeleme)
        private void KurslariYukle()
        {
            GridDoldur(@"
                SELECT kurs_id, baslik, seviye, fiyat, ortalama_puan, yorum_sayisi
                FROM Kurs
                ORDER BY kurs_id;
            ");
        }

        // ====== BUTONLAR: GÖRÜNTÜLEME ======

        private void btnKurslariYukle_Click(object sender, EventArgs e)
        {
            KurslariYukle();
        }

        private void btnKullaniciYukle_Click(object sender, EventArgs e)
        {
            GridDoldur(@"
                SELECT kullanici_id, ad, soyad, email, rol, kayit_tarihi, aktif
                FROM Kullanici
                ORDER BY kullanici_id;
            ");
        }

        private void btnKayitYukle_Click(object sender, EventArgs e)
        {
            GridDoldur(@"
                SELECT 
                    ka.kayit_id,
                    k.ad || ' ' || k.soyad AS ogrenci_adsoyad,
                    ku.baslik AS kurs_baslik,
                    ka.durum,
                    ka.kayit_tarihi
                FROM Kayit ka
                JOIN Ogrenci o   ON o.kullanici_id = ka.ogrenci_id
                JOIN Kullanici k ON k.kullanici_id = o.kullanici_id
                JOIN Kurs ku     ON ku.kurs_id = ka.kurs_id
                ORDER BY ka.kayit_id;
            ");
        }

        private void btnYorumYukle_Click(object sender, EventArgs e)
        {
            GridDoldur(@"
                SELECT 
                    y.yorum_id,
                    k.ad || ' ' || k.soyad AS ogrenci_adsoyad,
                    ku.baslik AS kurs_baslik,
                    y.puan,
                    y.yorum_tarihi
                FROM Yorum y
                JOIN Kullanici k ON k.kullanici_id = y.ogrenci_id
                JOIN Kurs ku     ON ku.kurs_id = y.kurs_id
                ORDER BY y.yorum_id;
            ");
        }

        private void btnOdemeYukle_Click(object sender, EventArgs e)
        {
            GridDoldur(@"
                SELECT odeme_id, kayit_id, tutar, odeme_tarihi, odeme_yontemi, durum
                FROM Odeme
                ORDER BY odeme_id;
            ");
        }

        // ====== BUTONLAR: FONKSİYON / TRIGGER TEST ======

        private void btnFonksiyonTest_Click(object sender, EventArgs e)
        {
            GridDoldur(@"
                SELECT 'ogrenci_quiz_dogru_sayisi(1,1)' AS test, ogrenci_quiz_dogru_sayisi(1,1) AS sonuc
                UNION ALL
                SELECT 'ogrenci_quiz_dogru_sayisi(2,1)' AS test, ogrenci_quiz_dogru_sayisi(2,1) AS sonuc;
            ");
        }

        private void btnTriggerTest_Click(object sender, EventArgs e)
        {
            GridDoldur(@"
                SELECT kurs_id, baslik, ortalama_puan, yorum_sayisi
                FROM Kurs
                ORDER BY kurs_id;
            ");
        }

        // ====== CRUD: ARAMA / EKLE / GÜNCELLE / SİL (KURS) ======

        // ARAMA: txtBaslik içinde geçen kursları getir
        private void btnAra_Click(object sender, EventArgs e)
        {
            string aranan = txtBaslik.Text.Trim();

            GridDoldur(@"
                SELECT kurs_id, baslik, seviye, fiyat, ortalama_puan, yorum_sayisi
                FROM Kurs
                WHERE baslik ILIKE '%' || @aranan || '%'
                ORDER BY kurs_id;
            ", aranan);
        }

        // EKLE: Kurs ekle (minimum alanlarla)
        private void btnEkle_Click(object sender, EventArgs e)
        {
            try
            {
                using (var conn = new NpgsqlConnection(_connString))
                {
                    conn.Open();

                    string sql = @"
                        INSERT INTO Kurs (baslik, seviye, fiyat, yayinda, olusturma_tarihi)
                        VALUES (@baslik, @seviye, @fiyat, TRUE, CURRENT_DATE);
                    ";

                    using (var cmd = new NpgsqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@baslik", txtBaslik.Text.Trim());
                        cmd.Parameters.AddWithValue("@seviye", txtSeviye.Text.Trim());
                        cmd.Parameters.AddWithValue("@fiyat", decimal.Parse(txtFiyat.Text.Trim()));
                        cmd.ExecuteNonQuery();
                    }
                }

                KurslariYukle();
                MessageBox.Show("Kurs eklendi.");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ekleme hatası:\n" + ex.Message);
            }
        }

        // GÜNCELLE: Seçili kursu güncelle
        private void btnGuncelle_Click(object sender, EventArgs e)
        {
            try
            {
                if (dgvKurslar.CurrentRow == null)
                {
                    MessageBox.Show("Güncellemek için listeden bir kurs seç.");
                    return;
                }

                int kursId = Convert.ToInt32(dgvKurslar.CurrentRow.Cells["kurs_id"].Value);

                using (var conn = new NpgsqlConnection(_connString))
                {
                    conn.Open();

                    string sql = @"
                        UPDATE Kurs
                        SET baslik = @baslik,
                            seviye = @seviye,
                            fiyat  = @fiyat
                        WHERE kurs_id = @id;
                    ";

                    using (var cmd = new NpgsqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@baslik", txtBaslik.Text.Trim());
                        cmd.Parameters.AddWithValue("@seviye", txtSeviye.Text.Trim());
                        cmd.Parameters.AddWithValue("@fiyat", decimal.Parse(txtFiyat.Text.Trim()));
                        cmd.Parameters.AddWithValue("@id", kursId);
                        cmd.ExecuteNonQuery();
                    }
                }

                KurslariYukle();
                MessageBox.Show("Kurs güncellendi.");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Güncelleme hatası:\n" + ex.Message);
            }
        }

        // SİL: Seçili kursu sil
        private void btnSil_Click(object sender, EventArgs e)
        {
            try
            {
                if (dgvKurslar.CurrentRow == null)
                {
                    MessageBox.Show("Silmek için listeden bir kurs seç.");
                    return;
                }

                int kursId = Convert.ToInt32(dgvKurslar.CurrentRow.Cells["kurs_id"].Value);

                var onay = MessageBox.Show("Seçili kurs silinsin mi?", "Onay", MessageBoxButtons.YesNo);
                if (onay != DialogResult.Yes) return;

                using (var conn = new NpgsqlConnection(_connString))
                {
                    conn.Open();

                    string sql = "DELETE FROM Kurs WHERE kurs_id = @id;";

                    using (var cmd = new NpgsqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", kursId);
                        cmd.ExecuteNonQuery();
                    }
                }

                KurslariYukle();
                MessageBox.Show("Kurs silindi.");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Silme hatası:\n" + ex.Message);
            }
        }

        // DataGridView’den satır seçilince textbox’ları doldur (Güncelle/Sil için kolaylık)
        private void dgvKurslar_SelectionChanged(object sender, EventArgs e)
        {
            try
            {
                if (dgvKurslar.CurrentRow == null) return;
                if (dgvKurslar.CurrentRow.Cells["baslik"] == null) return;

                txtBaslik.Text = dgvKurslar.CurrentRow.Cells["baslik"].Value?.ToString();
                txtSeviye.Text = dgvKurslar.CurrentRow.Cells["seviye"].Value?.ToString();
                txtFiyat.Text = dgvKurslar.CurrentRow.Cells["fiyat"].Value?.ToString();
            }
            catch
            {
                // Grid farklı bir tablo gösterirken bu event tetiklenebilir, sessiz geçiyoruz.
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // İstersen form açılınca kursları otomatik yüklemek için:
            // KurslariYukle();
        }

        
    }
}
