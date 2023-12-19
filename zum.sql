-- MySQL dump 10.13  Distrib 8.0.35, for Linux (x86_64)
--
-- Host: localhost    Database: zum
-- ------------------------------------------------------
-- Server version	8.0.35-0ubuntu0.22.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `blog_posts`
--

DROP TABLE IF EXISTS `blog_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `parent` int DEFAULT NULL,
  `group_id` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_posts`
--

LOCK TABLES `blog_posts` WRITE;
/*!40000 ALTER TABLE `blog_posts` DISABLE KEYS */;
INSERT INTO `blog_posts` VALUES (3,1,'','## Lika Liku Deployment\r\n\r\nMasalah pertama, 00:35, tidak bisa install flask-mysqldb.\r\n\r\nSolusinya, ada di [jawaban StackOverflow ini](https://stackoverflow.com/questions/76875507/can-not-install-apache-airflow-providers-mysql-pkg-config-error)\r\n\r\n```\r\nmysql_config --cflags\r\nmysql_config --libs\r\nexport MYSQLCLIENT_CFLAGS=\"isi dari mysql_config --cflags\"\r\nexport MYSQLCLIENT_LDFLAGS=\"mysql_config --libs\"\r\n```\r\n\r\nMasalah kedua, `ImportError: cannot import name \'_app_ctx_stack\' from \'flask.ctx\'`\r\n\r\nSolusinya, ada di [jawaban StackOverflow ini](https://stackoverflow.com/questions/73340344/cannot-use-module-aioflaskpython-importerror-cannot-import-name-app-ctx-st)\r\n\r\n```\r\npip uninstall flask\r\npip install flask==2.1.3\r\n```\r\n\r\nMasalah ketiga, 00:48, `ImportError: cannot import name \'url_quote\' from \'werkzeug.urls\'`\r\n\r\nSolusinya, ada di [jawaban StackOverflow ini](https://stackoverflow.com/questions/77213053/why-did-flask-start-failing-with-importerror-cannot-import-name-url-quote-fr)\r\n\r\n```\r\npip uninstall werkzeug\r\npip install werkzeug==2.2.2\r\n```\r\n\r\nMasalah keempat, ternyata deploy Flask itu harus tetap pakai httpd.\r\n\r\nSolusinya, ada di [artikel blog ini](https://www.askpython.com/python-modules/flask/deploy-flask-app-on-vps).\r\n\r\nPertama, install httpd dan modul wsginya.\r\n\r\n```\r\nsudo apt install apache2\r\nsudo apt-get install libapache2-mod-wsgi-py3\r\n```\r\n\r\nOh iya, harus pakai `libapache2-mod-wsgi-py3` karena artikel di blog tersebut ternyata [sudah tidak update](https://stackoverflow.com/questions/2081776/couldnt-find-package-libapache2-mod-wsgi).\r\n\r\nSetelah itu, tempatkan folder projectnya di dalam direktori `/var/www/html`. Buat file baru `app.wsgi` di dalam folder projectnya dengan isi berikut : \r\n\r\n```\r\nimport sys\r\nsys.path.insert(0, \'/var/www/html/zum\')\r\nfrom app import app as application\r\n```\r\n\r\nLalu, buka `/etc/apache2/sites-enabled/000-default.conf`, tambahkan baris berikut di bawah bagian `DocumentRoot`.\r\n\r\n```\r\nWSGIDaemonProcess zum threads=5\r\nWSGIScriptAlias / /var/www/html/zum/app.wsgi\r\n \r\n<Directory zum>\r\n    WSGIProcessGroup zum\r\n    WSGIApplicationGroup %{GLOBAL}\r\n    Order deny,allow\r\n    Allow from all\r\n</Directory>\r\n```\r\n\r\nLalu, restart apache\r\n\r\n```\r\nsudo service apache2 restart\r\n```\r\n\r\nMasalah terakhir, akses Flask ke MySQL masih terus ditolak.\r\n\r\nSolusinya, ada di [jawaban StackOverflow ini](https://stackoverflow.com/questions/41645309/mysql-error-access-denied-for-user-rootlocalhost)\r\n\r\n```\r\nsudo mysql\r\nALTER USER \'root\'@\'localhost\' IDENTIFIED WITH mysql_native_password BY \'root\';\r\n```\r\n\r\nLalu, modifikasi sedikit pada `app.py`-nya, supaya pakai user=root, pw=root.\r\n\r\nSelesai.\r\n\r\n---\r\n\r\n### Kesimpulan\r\n\r\n* Folder projectnya ada di `/var/www/html/zum/`\r\n* Setelah memodifikasi isi folder project, restart apachenya kalau mau tahu hasilnya (`sudo service apache2 restart`)\r\n* Kalau mau cek error, buka error log httpd pakai `nano /var/log/apache2/error.log`','2023-12-16 23:41:15',NULL,NULL),(5,1,'','### Sekilas Info\r\n\r\nSource code kasarnya ada [di sini](https://github.com/altilunium/zum).\r\n\r\nKode ini lancar jaya kalau dijalanin di Windows, tapi agak rusak kalau dijalanin di Ubuntu VPS. Oleh karena itu perlu penyesuaian disana-sini yang belum sempat terdokumentasikan. Silahkan masuk ke VPSnya lalu cek skema database MySQLnya langsung dan akses source code versi Ubuntunya di direktori \"var/www/html/zum\".\r\n\r\nKode ini dibuat menggunakan [bantuan ChatGPT](https://chat.openai.com/share/7b542235-4403-407e-a65a-3d5bc3103cde).\r\n\r\nPanduan deployment kode ini di Windows :\r\n\r\n1. Pip install flask\r\n2. Pip install flask-mysqldb\r\n3. Dump a.sql ke MySQL\r\n4. Buka app2.py, sesuaikan konfigurasi username-password MySQLnya dengan konfigurasi MySQL lokal di PC kamu\r\n5. Jalankan app2.py nya (mungkin sekalian, hapus saja app.py nya)\r\n\r\nWhat\'s next :\r\n\r\n1. Rapihin UI-nya. Wajib mobile-friendly. Minimal sekelas Github ([seperti ini](https://github.com/JannisX11/snowstorm/issues/30)) atau Reddit.\r\n2. Gimana caranya setiap postingan itu punya permalink (yang enak dilihat) dan bisa diakses oleh pengguna yang belum login. Intinya, postingan di platform ini bisa dishare keluar gitu.\r\n3. Tiap postingan, bisa di comment.\r\n4. Fitur subkomunitas. Intinya bikin \"grup\" gitulah. Orang bisa \"gabung\", \"posting\" dan \"keluar\" dari grup.\r\n\r\nEmpat (usulan) [sprint backlog](https://www.scrum.org/resources/what-is-a-sprint-backlog) ini bisa dibagi bagi ke yang berminat ngerjainnya.\r\n\r\nOh ya, VPSnya itu Rp 30.000 per bulan (edisi promo, harga naik bulan depan, belum termasuk PPN dan ongkos transfer QRIS). Semalam dibayarin sama Eko. Sekarang yang megang kunci servernya itu saya dan Eko. DM aja kalau mau akses ngedeploy.','2023-12-17 05:42:37',NULL,NULL),(6,1,'','### Markdown\r\n\r\nAnda bisa posting pakai Markdown di sini. Baca panduan lengkapnya [di sini](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)','2023-12-17 05:45:38',NULL,NULL),(7,1,'','Mantab!','2023-12-17 16:28:48',6,NULL),(8,1,'','Sudah bisa chained comment sekarang :D','2023-12-17 16:29:09',7,NULL),(9,1,'','Mwehehehe','2023-12-17 16:29:21',6,NULL),(10,1,'','Beneran?','2023-12-17 16:31:34',8,NULL),(11,1,'','Ho oh','2023-12-17 16:31:42',10,NULL),(12,1,'','Mantap','2023-12-17 16:32:02',8,NULL),(13,1,'','# Apakah bisa comment pakai markdown ?','2023-12-17 16:34:17',5,NULL),(14,1,'','Ternyata ***bisa*** toh','2023-12-17 16:34:43',13,NULL),(15,1,'','Halo!','2023-12-17 16:38:33',1,NULL),(16,1,'','# Subkategori /a/\r\n\r\nDebut subkategori /a/!','2023-12-17 17:26:31',NULL,'a'),(17,1,'','Mantap!','2023-12-17 17:26:40',16,NULL),(18,1,'','### Fitur subkategori\r\n\r\n* [http://202.10.40.128/grup/a](http://202.10.40.128/grup/a)','2023-12-17 17:28:01',NULL,NULL),(19,1,'','Jadinya, tiap komunitas punya tempatnya masing masing. Postingannya tidak tercampur ^^','2023-12-17 17:30:56',18,NULL),(20,1,'','Fitur utama terakhir : moderasi dan pengawasan konten.','2023-12-17 17:32:05',19,NULL),(21,1,'','Jangan lupa load balancing kalau kalau postingannya membludak.','2023-12-17 17:32:59',19,NULL),(22,1,'','Dan **JANGAN DIRILIS DULU KE PUBLIK** kalau fitur moderasi dan monitoringnya belum ada. Nanti kena UU ITE bahaya kita.','2023-12-17 17:34:12',20,NULL),(23,1,'','.... dan, keempat sprint backlog ini sudah selesai hari ini. yey ^__^','2023-12-17 17:39:11',5,NULL),(24,1,'','Lah, kan belum bisa \"gabung\" dan \"keluar\" dari grup?','2023-12-17 17:39:53',23,NULL),(25,1,'','Sepertinya itu cuma nice to have aja deh. Belum terlalu urgent.\r\n\r\nEh, btw. Ku barusan nemu bug.','2023-12-17 17:40:52',24,NULL),(26,1,'','Bug apa?','2023-12-17 17:40:59',25,NULL),(27,1,'','Servernya rusak kalau postingan kita mengandung emoji.. Wkwk ','2023-12-17 17:41:30',26,NULL),(28,1,'','Nah loh.. Wkwk','2023-12-17 17:41:58',27,NULL),(29,1,'','![](https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Osechi_001.jpg/500px-Osechi_001.jpg)','2023-12-17 17:42:49',13,NULL),(30,1,'','Bisa posting gambar juga. Tapi, gambarnya kepotong kalau dimensinya kegedean. xD','2023-12-17 17:43:27',29,NULL),(31,1,'','![](https://i.ibb.co/J3cC0P0/Screenshot-483.png)\r\n\r\nMonitoring sudah jadi. Kalau ada yang posting aneh-aneh, bisa langsung dihapus via dashboard superadmin. \r\n\r\nSiap rilis :v','2023-12-18 07:35:40',22,NULL),(32,1,'','Fitur permaban juga sudah siap. Ambil user agent dan IP dari access.log httpd, dan pasang blacklist langsung pakai dua informasi tersebut.','2023-12-18 07:38:19',22,NULL),(33,1,'','### Alternatif connect ke VPS\r\n\r\n#### Windows\r\n\r\nDownload [Putty](https://www.putty.org/), masukkan IP server, connect. Lalu masukkan username dan password.\r\n\r\n#### Android\r\n\r\nDownload [Termux](https://termux.dev/en/). \"ssh username@ipserver\", lalu masukkan password.','2023-12-19 03:42:10',NULL,NULL);
/*!40000 ALTER TABLE `blog_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `log`
--

DROP TABLE IF EXISTS `log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `actor` text NOT NULL,
  `action` text NOT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log`
--

LOCK TABLES `log` WRITE;
/*!40000 ALTER TABLE `log` DISABLE KEYS */;
INSERT INTO `log` VALUES (1,'rtnf','register','2023-12-16 23:06:42'),(2,'rtnf','login','2023-12-16 23:06:51'),(3,'rtnf','logout','2023-12-16 23:08:30'),(4,'rtnf2','register','2023-12-16 23:08:40'),(5,'rtnf2','login','2023-12-16 23:08:48'),(6,'rtnf2','logout','2023-12-16 23:11:34'),(7,'rtnf3','register','2023-12-16 23:11:44'),(8,'rtnf3','login','2023-12-16 23:11:49'),(9,'rtnf3','logout','2023-12-16 23:16:56'),(10,'rtnf','login','2023-12-16 23:17:01'),(11,'rtnf','login','2023-12-16 23:18:41'),(12,'rtnf','logout','2023-12-16 23:20:06'),(13,'rtnf','login','2023-12-16 23:20:12'),(14,'rtnf','login','2023-12-16 23:45:08'),(15,'rtnf','login','2023-12-16 23:45:44'),(16,'rtnf','login','2023-12-16 23:45:55'),(17,'rtnf','logout','2023-12-16 23:59:32'),(18,'rtnf','login','2023-12-16 23:59:37'),(19,'lila_rosa_2024','register','2023-12-17 04:49:18'),(20,'lila_rosa_2024','login','2023-12-17 04:49:24'),(21,'rtnf','logout','2023-12-17 05:00:07'),(22,'rtnf','login','2023-12-17 05:00:11'),(23,'rtnf','login','2023-12-17 05:00:11'),(24,'rtnf','login','2023-12-17 08:51:11'),(25,'rtnf','login','2023-12-17 10:58:32'),(26,'rtnf','login','2023-12-17 16:37:51'),(27,'rtnf','login','2023-12-17 16:37:52'),(28,'rtnf','login','2023-12-18 00:38:33'),(29,'rtnf','login','2023-12-19 03:39:20'),(30,'rtnf','login','2023-12-19 03:39:21'),(31,'rtnf','logout','2023-12-19 15:19:19'),(32,'rtnf','login','2023-12-19 15:19:26');
/*!40000 ALTER TABLE `log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` text NOT NULL,
  `password` text NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'rtnf','pbkdf2:sha256:260000$84AM6FTsQFXvEAKO$4dc66e3a87be90e26b37740684aa5f20e35830a897bd82ddd75269ec53ec299b','2023-12-16 23:06:42'),(2,'rtnf2','pbkdf2:sha256:260000$ONNyqrfi28lprvwN$4da6e58127702b8ef74dcfa572264188d513dec619685e91de2693ee7c8a0fc7','2023-12-16 23:08:40'),(3,'rtnf3','pbkdf2:sha256:260000$qJAOXrdkVygaiT8M$d4b4ab44480cb9244e289fffe08ae3511ec42852b97fb17d0a8cff676177a5f5','2023-12-16 23:11:44'),(4,'lila_rosa_2024','pbkdf2:sha256:260000$hSu5kyaCfZGjkEf6$221efc1966017121120fe63435f1cc62e81d5b4d4a3cae37aa6958e39e331b7f','2023-12-17 04:49:18');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-12-19 15:20:28
