namespace TriGala
{
    partial class frmMain
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.btn_Start = new System.Windows.Forms.Button();
            this.txtDataDa = new System.Windows.Forms.MaskedTextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label3 = new System.Windows.Forms.Label();
            this.txtIdCliente = new System.Windows.Forms.TextBox();
            this.txtDataA = new System.Windows.Forms.MaskedTextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.btnManuale = new System.Windows.Forms.Button();
            this.clbEntita = new System.Windows.Forms.CheckedListBox();
            this.label4 = new System.Windows.Forms.Label();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // btn_Start
            // 
            this.btn_Start.Location = new System.Drawing.Point(398, 237);
            this.btn_Start.Name = "btn_Start";
            this.btn_Start.Size = new System.Drawing.Size(97, 49);
            this.btn_Start.TabIndex = 0;
            this.btn_Start.Text = "Simulazione processo automatico";
            this.btn_Start.UseVisualStyleBackColor = true;
            this.btn_Start.Visible = false;
            this.btn_Start.Click += new System.EventHandler(this.btn_Start_Click);
            // 
            // txtDataDa
            // 
            this.txtDataDa.Location = new System.Drawing.Point(84, 28);
            this.txtDataDa.Mask = "00/00/0000";
            this.txtDataDa.Name = "txtDataDa";
            this.txtDataDa.Size = new System.Drawing.Size(79, 20);
            this.txtDataDa.TabIndex = 1;
            this.txtDataDa.ValidatingType = typeof(System.DateTime);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(17, 31);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(50, 13);
            this.label1.TabIndex = 2;
            this.label1.Text = "Data Da:";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.txtIdCliente);
            this.groupBox1.Controls.Add(this.txtDataA);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.txtDataDa);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Location = new System.Drawing.Point(11, 228);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(381, 122);
            this.groupBox1.TabIndex = 3;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Parametri per l\'elaborazione";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(17, 83);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(51, 13);
            this.label3.TabIndex = 6;
            this.label3.Text = "Id Cliente";
            // 
            // txtIdCliente
            // 
            this.txtIdCliente.Location = new System.Drawing.Point(84, 80);
            this.txtIdCliente.Name = "txtIdCliente";
            this.txtIdCliente.Size = new System.Drawing.Size(79, 20);
            this.txtIdCliente.TabIndex = 5;
            // 
            // txtDataA
            // 
            this.txtDataA.Location = new System.Drawing.Point(84, 54);
            this.txtDataA.Mask = "00/00/0000";
            this.txtDataA.Name = "txtDataA";
            this.txtDataA.Size = new System.Drawing.Size(79, 20);
            this.txtDataA.TabIndex = 3;
            this.txtDataA.ValidatingType = typeof(System.DateTime);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(17, 57);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(43, 13);
            this.label2.TabIndex = 4;
            this.label2.Text = "Data A:";
            // 
            // btnManuale
            // 
            this.btnManuale.Location = new System.Drawing.Point(398, 302);
            this.btnManuale.Name = "btnManuale";
            this.btnManuale.Size = new System.Drawing.Size(97, 49);
            this.btnManuale.TabIndex = 4;
            this.btnManuale.Text = "Avvia Processo Manuale";
            this.btnManuale.UseVisualStyleBackColor = true;
            this.btnManuale.Click += new System.EventHandler(this.btnManuale_Click);
            // 
            // clbEntita
            // 
            this.clbEntita.FormattingEnabled = true;
            this.clbEntita.Location = new System.Drawing.Point(11, 27);
            this.clbEntita.Name = "clbEntita";
            this.clbEntita.Size = new System.Drawing.Size(381, 184);
            this.clbEntita.TabIndex = 5;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(28, 9);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(97, 13);
            this.label4.TabIndex = 6;
            this.label4.Text = "Entità da Elaborare";
            // 
            // frmMain
            // 
            this.AcceptButton = this.btnManuale;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(518, 363);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.clbEntita);
            this.Controls.Add(this.btnManuale);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.btn_Start);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.MinimizeBox = false;
            this.Name = "frmMain";
            this.Text = "TriGala";
            this.Load += new System.EventHandler(this.frmMain_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btn_Start;
        private System.Windows.Forms.MaskedTextBox txtDataDa;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox txtIdCliente;
        private System.Windows.Forms.MaskedTextBox txtDataA;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button btnManuale;
        private System.Windows.Forms.CheckedListBox clbEntita;
        private System.Windows.Forms.Label label4;
    }
}

