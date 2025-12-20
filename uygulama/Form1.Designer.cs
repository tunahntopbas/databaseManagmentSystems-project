namespace online_egitim_sistemi
{
    partial class Form1
    {
        /// <summary>
        ///Gerekli tasarımcı değişkeni.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///Kullanılan tüm kaynakları temizleyin.
        /// </summary>
        ///<param name="disposing">yönetilen kaynaklar dispose edilmeliyse doğru; aksi halde yanlış.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer üretilen kod

        /// <summary>
        /// Tasarımcı desteği için gerekli metot - bu metodun 
        ///içeriğini kod düzenleyici ile değiştirmeyin.
        /// </summary>
        private void InitializeComponent()
        {
            this.dgvKurslar = new System.Windows.Forms.DataGridView();
            this.btnKurslariYukle = new System.Windows.Forms.Button();
            this.btnKullaniciYukle = new System.Windows.Forms.Button();
            this.btnKayitYukle = new System.Windows.Forms.Button();
            this.btnYorumYukle = new System.Windows.Forms.Button();
            this.btnTriggerTest = new System.Windows.Forms.Button();
            this.btnFonksiyonTest = new System.Windows.Forms.Button();
            this.btnOdemeYukle = new System.Windows.Forms.Button();
            this.btnAra = new System.Windows.Forms.Button();
            this.btnEkle = new System.Windows.Forms.Button();
            this.btnGuncelle = new System.Windows.Forms.Button();
            this.btnSil = new System.Windows.Forms.Button();
            this.txtBaslik = new System.Windows.Forms.TextBox();
            this.txtSeviye = new System.Windows.Forms.TextBox();
            this.txtFiyat = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.dgvKurslar)).BeginInit();
            this.SuspendLayout();
            // 
            // dgvKurslar
            // 
            this.dgvKurslar.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvKurslar.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.dgvKurslar.Location = new System.Drawing.Point(0, 334);
            this.dgvKurslar.Name = "dgvKurslar";
            this.dgvKurslar.RowHeadersWidth = 51;
            this.dgvKurslar.RowTemplate.Height = 24;
            this.dgvKurslar.Size = new System.Drawing.Size(1461, 300);
            this.dgvKurslar.TabIndex = 0;
            // 
            // btnKurslariYukle
            // 
            this.btnKurslariYukle.Location = new System.Drawing.Point(0, 282);
            this.btnKurslariYukle.Name = "btnKurslariYukle";
            this.btnKurslariYukle.Size = new System.Drawing.Size(120, 46);
            this.btnKurslariYukle.TabIndex = 1;
            this.btnKurslariYukle.Text = "Kursları Yükle";
            this.btnKurslariYukle.UseVisualStyleBackColor = true;
            this.btnKurslariYukle.Click += new System.EventHandler(this.btnKurslariYukle_Click);
            // 
            // btnKullaniciYukle
            // 
            this.btnKullaniciYukle.Location = new System.Drawing.Point(126, 282);
            this.btnKullaniciYukle.Name = "btnKullaniciYukle";
            this.btnKullaniciYukle.Size = new System.Drawing.Size(120, 46);
            this.btnKullaniciYukle.TabIndex = 2;
            this.btnKullaniciYukle.Text = "Kullanıcıları Yükle";
            this.btnKullaniciYukle.UseVisualStyleBackColor = true;
            this.btnKullaniciYukle.Click += new System.EventHandler(this.btnKullaniciYukle_Click);
            // 
            // btnKayitYukle
            // 
            this.btnKayitYukle.Location = new System.Drawing.Point(252, 282);
            this.btnKayitYukle.Name = "btnKayitYukle";
            this.btnKayitYukle.Size = new System.Drawing.Size(120, 46);
            this.btnKayitYukle.TabIndex = 3;
            this.btnKayitYukle.Text = "Kayıtları Yükle";
            this.btnKayitYukle.UseVisualStyleBackColor = true;
            this.btnKayitYukle.Click += new System.EventHandler(this.btnKayitYukle_Click);
            // 
            // btnYorumYukle
            // 
            this.btnYorumYukle.Location = new System.Drawing.Point(378, 282);
            this.btnYorumYukle.Name = "btnYorumYukle";
            this.btnYorumYukle.Size = new System.Drawing.Size(120, 46);
            this.btnYorumYukle.TabIndex = 4;
            this.btnYorumYukle.Text = "Yorumları Yükle";
            this.btnYorumYukle.UseVisualStyleBackColor = true;
            this.btnYorumYukle.Click += new System.EventHandler(this.btnYorumYukle_Click);
            // 
            // btnTriggerTest
            // 
            this.btnTriggerTest.Location = new System.Drawing.Point(138, 12);
            this.btnTriggerTest.Name = "btnTriggerTest";
            this.btnTriggerTest.Size = new System.Drawing.Size(120, 46);
            this.btnTriggerTest.TabIndex = 5;
            this.btnTriggerTest.Text = "Trigger Test";
            this.btnTriggerTest.UseVisualStyleBackColor = true;
            this.btnTriggerTest.Click += new System.EventHandler(this.btnTriggerTest_Click);
            // 
            // btnFonksiyonTest
            // 
            this.btnFonksiyonTest.Location = new System.Drawing.Point(12, 12);
            this.btnFonksiyonTest.Name = "btnFonksiyonTest";
            this.btnFonksiyonTest.Size = new System.Drawing.Size(120, 46);
            this.btnFonksiyonTest.TabIndex = 6;
            this.btnFonksiyonTest.Text = "Fonksiyon Test";
            this.btnFonksiyonTest.UseVisualStyleBackColor = true;
            this.btnFonksiyonTest.Click += new System.EventHandler(this.btnFonksiyonTest_Click);
            // 
            // btnOdemeYukle
            // 
            this.btnOdemeYukle.Location = new System.Drawing.Point(504, 282);
            this.btnOdemeYukle.Name = "btnOdemeYukle";
            this.btnOdemeYukle.Size = new System.Drawing.Size(120, 46);
            this.btnOdemeYukle.TabIndex = 7;
            this.btnOdemeYukle.Text = "Ödemeleri Yükle";
            this.btnOdemeYukle.UseVisualStyleBackColor = true;
            this.btnOdemeYukle.Click += new System.EventHandler(this.btnOdemeYukle_Click);
            // 
            // btnAra
            // 
            this.btnAra.Location = new System.Drawing.Point(935, 12);
            this.btnAra.Name = "btnAra";
            this.btnAra.Size = new System.Drawing.Size(120, 46);
            this.btnAra.TabIndex = 8;
            this.btnAra.Text = "Ara";
            this.btnAra.UseVisualStyleBackColor = true;
            this.btnAra.Click += new System.EventHandler(this.btnAra_Click);

            // 
            // btnEkle
            // 
            this.btnEkle.Location = new System.Drawing.Point(1061, 12);
            this.btnEkle.Name = "btnEkle";
            this.btnEkle.Size = new System.Drawing.Size(120, 46);
            this.btnEkle.TabIndex = 9;
            this.btnEkle.Text = "Ekle";
            this.btnEkle.UseVisualStyleBackColor = true;
            this.btnEkle.Click += new System.EventHandler(this.btnEkle_Click);

            // 
            // btnGuncelle
            // 
            this.btnGuncelle.Location = new System.Drawing.Point(1187, 12);
            this.btnGuncelle.Name = "btnGuncelle";
            this.btnGuncelle.Size = new System.Drawing.Size(120, 46);
            this.btnGuncelle.TabIndex = 10;
            this.btnGuncelle.Text = "Güncelle";
            this.btnGuncelle.UseVisualStyleBackColor = true;
            this.btnGuncelle.Click += new System.EventHandler(this.btnGuncelle_Click);

            // 
            // btnSil
            // 
            this.btnSil.Location = new System.Drawing.Point(1313, 12);
            this.btnSil.Name = "btnSil";
            this.btnSil.Size = new System.Drawing.Size(120, 46);
            this.btnSil.TabIndex = 11;
            this.btnSil.Text = "Sil";
            this.btnSil.UseVisualStyleBackColor = true;
            this.btnSil.Click += new System.EventHandler(this.btnSil_Click);

            // 
            // txtBaslik
            // 
            this.txtBaslik.Location = new System.Drawing.Point(925, 122);
            this.txtBaslik.Name = "txtBaslik";
            this.txtBaslik.Size = new System.Drawing.Size(100, 22);
            this.txtBaslik.TabIndex = 12;
            // 
            // txtSeviye
            // 
            this.txtSeviye.Location = new System.Drawing.Point(1061, 122);
            this.txtSeviye.Name = "txtSeviye";
            this.txtSeviye.Size = new System.Drawing.Size(100, 22);
            this.txtSeviye.TabIndex = 13;
            // 
            // txtFiyat
            // 
            this.txtFiyat.Location = new System.Drawing.Point(1207, 122);
            this.txtFiyat.Name = "txtFiyat";
            this.txtFiyat.Size = new System.Drawing.Size(100, 22);
            this.txtFiyat.TabIndex = 14;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(925, 100);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(73, 16);
            this.label1.TabIndex = 15;
            this.label1.Text = "Kurs Başlık";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(1058, 103);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(49, 16);
            this.label2.TabIndex = 16;
            this.label2.Text = "Seviye";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(1204, 103);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(36, 16);
            this.label3.TabIndex = 17;
            this.label3.Text = "Fiyat";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1461, 634);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.txtFiyat);
            this.Controls.Add(this.txtSeviye);
            this.Controls.Add(this.txtBaslik);
            this.Controls.Add(this.btnSil);
            this.Controls.Add(this.btnGuncelle);
            this.Controls.Add(this.btnEkle);
            this.Controls.Add(this.btnAra);
            this.Controls.Add(this.btnOdemeYukle);
            this.Controls.Add(this.btnFonksiyonTest);
            this.Controls.Add(this.btnTriggerTest);
            this.Controls.Add(this.btnYorumYukle);
            this.Controls.Add(this.btnKayitYukle);
            this.Controls.Add(this.btnKullaniciYukle);
            this.Controls.Add(this.btnKurslariYukle);
            this.Controls.Add(this.dgvKurslar);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dgvKurslar)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView dgvKurslar;
        private System.Windows.Forms.Button btnKurslariYukle;
        private System.Windows.Forms.Button btnKullaniciYukle;
        private System.Windows.Forms.Button btnKayitYukle;
        private System.Windows.Forms.Button btnYorumYukle;
        private System.Windows.Forms.Button btnTriggerTest;
        private System.Windows.Forms.Button btnFonksiyonTest;
        private System.Windows.Forms.Button btnOdemeYukle;
        private System.Windows.Forms.Button btnAra;
        private System.Windows.Forms.Button btnEkle;
        private System.Windows.Forms.Button btnGuncelle;
        private System.Windows.Forms.Button btnSil;
        private System.Windows.Forms.TextBox txtBaslik;
        private System.Windows.Forms.TextBox txtSeviye;
        private System.Windows.Forms.TextBox txtFiyat;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
    }
}

