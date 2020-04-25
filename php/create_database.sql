/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of Chachatte Team application.
 *
 * Chachatte Team is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chachatte Team is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chachatte Team. If not, see <http://www.gnu.org/licenses/>.
 */

CREATE TABLE IF NOT EXISTS `members` (
  `id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(64) NOT NULL,
  `last_name` varchar(64) NOT NULL,
  `email` varchar(128) NOT NULL,
  `password` varchar(255) NOT NULL,
  `avatar` varchar(255) NOT NULL,
  `active` boolean NOT NULL DEFAULT FALSE,
  `admin` boolean NOT NULL DEFAULT FALSE,
  `phone` varchar(13) NULL,
  `bike` varchar(64) NULL,
  `registration_date` datetime NOT NULL,
  `created_on` timestamp NOT NULL,
  `modified_on` timestamp NULL,
  PRIMARY KEY (`id`),
  UNIQUE(email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `tracks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `distance` int NULL,
  `lap_record` int NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `photos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(64) NOT NULL,
  `description` text NULL,
  `link` text NOT NULL,
  `created_on` timestamp NOT NULL,
  `modified_on` timestamp NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `news` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `content` text NOT NULL,
  `news_date` datetime NOT NULL,
  `created_on` timestamp NOT NULL,
  `created_by` int NOT NULL,
  `modified_on` timestamp NULL,
  `modified_by` int NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT fk_news_created_by FOREIGN KEY (created_by) REFERENCES members(id),
  CONSTRAINT fk_news_modified_by FOREIGN KEY (modified_by) REFERENCES members(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `description` text NULL,
  `event_date` datetime NOT NULL,
  `track_id` int NOT NULL,
  `organizer` varchar(64) NOT NULL,
  `price` decimal(6,2) NOT NULL,
  `created_on` timestamp NOT NULL,
  `created_by` int NOT NULL,
  `modified_on` timestamp NULL,
  `modified_by` int NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT fk_events_track FOREIGN KEY (track_id) REFERENCES tracks(id),
  CONSTRAINT fk_events_created_by FOREIGN KEY (created_by) REFERENCES members(id),
  CONSTRAINT fk_events_modified_by FOREIGN KEY (modified_by) REFERENCES members(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `events_members` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event_id` int NOT NULL,
  `member_id` int NOT NULL,
  `created_on` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT fk_events_members_event FOREIGN KEY (event_id) REFERENCES events(id),
  CONSTRAINT fk_events_members_member FOREIGN KEY (member_id) REFERENCES members(id),
  UNIQUE(event_id, member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `news_members` (
  `id` int NOT NULL AUTO_INCREMENT,
  `news_id` int NOT NULL,
  `member_id` int NOT NULL,
  `created_on` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT fk_news_members_news FOREIGN KEY (news_id) REFERENCES news(id),
  CONSTRAINT fk_news_members_member FOREIGN KEY (member_id) REFERENCES members(id),
  UNIQUE(news_id, member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `track_id` int NOT NULL,
  `member_id` int NOT NULL,
  `lap_time` int NOT NULL,
  `record_date` date NOT NULL,
  `conditions` varchar(32) NOT NULL,
  `comments` text NULL,
  `created_on` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT fk_records_track FOREIGN KEY (track_id) REFERENCES tracks(id),
  CONSTRAINT fk_records_member FOREIGN KEY (member_id) REFERENCES members(id),
  UNIQUE(track_id, member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

INSERT INTO `members` (`id`, `first_name`, `last_name`, `email`, `password`, `active`, `admin`, `phone`, `bike`, `registration_date`, `created_on`, `modified_on`) VALUES
(1, 'Bob', 'Admin', 'bob.admin@wanadoo.fr', '$2y$10$MuLwPiQkTlcKEbGX6ztzAOxGlqK7ddglgDXcYBRBFDwkM.AQy63EK', 1, 0, '+33 123456789', 'Honda CBR 600 RR 2007', '2016-07-11 00:00:00', '2019-06-10 13:44:26', '2018-07-01 07:30:54'),
(2, 'Stéphane', 'Verger', 'steph.verger@orange.fr', '', 0, 0, '+72 777992834', 'Kawasaki ZX6R 636 2015', '2016-06-30 00:00:00', '2019-02-11 21:11:24', NULL),
(3, 'Coralie', 'Archambault', 'coralie.ar@free.fr', '', 0, 0, '+56 856755465', 'Suzuki GSXR 750 2007', '2019-01-11 21:44:00', '2019-02-11 21:07:37', NULL),
(4, 'Etienne', 'Moquin', 'etienne.moquin@gmail.com', '', 0, 0, '+34 583683774', 'Yamaha R1 2016', '2019-01-31 23:27:00', '2019-02-11 21:06:59', NULL),
(5, 'Dylan', 'Gabriaux', 'dylangabriaux@orange.fr', '', 0, 0, '+03 381647281', 'BMW S1000RR', '2017-05-16 00:00:00', '2019-02-11 21:08:00', NULL),
(6, 'André', 'De La Vergne', 'Andre.vergne@test.fr', '', 0, 0, '+77 373737377', 'Aprilia RSV4 2010', '2019-02-11 22:12:00', '2019-02-11 21:12:34', NULL),
(7, 'Gilles', 'Arpin', 'gillearpin@test.ch', '', 0, 0, '+02 883773736', 'Honda 1000 CBR 2012', '2019-02-11 22:13:00', '2019-02-11 21:13:47', NULL),
(8, 'Frédéric', 'Dupond', 'Fred.dupond@test.fr', '', 0, 0, '+03 383747278', 'Ducati 848 2012', '2019-02-11 22:15:00', '2019-02-11 21:15:59', NULL),
(9, 'John', 'Doe', 'john.doe@mail.fr', '', 0, 0, '+33608080808', 'Honda CBR 600 RR 2010', '2018-01-30 00:00:00', '2018-07-01 09:30:54', NULL),
(10, 'Jenna', 'Jonhnson', 'jenna.jonhnson@mail.com', '', 0, 0, NULL, 'Kawasaki ZX6R 636 2013', '2018-02-19 13:56:42', '2018-07-01 09:37:12', NULL);

INSERT INTO `news` (`id`, `title`, `content`, `news_date`, `created_on`, `created_by`, `modified_on`, `modified_by`) VALUES
(1, 'Repas du club', 'Repas de club avec tartiflettre géante', '2018-05-30 23:17:12', '2018-06-01 11:50:41', 1, NULL, NULL),
(2, 'Réunion de dèbut d''année', 'Réunion de dèbut d''année pour oganiser les roulages', '2018-05-30 23:31:44', '2018-06-01 00:35:07', 1, NULL, NULL),
(3, 'Réunion pour organisation foire au 2 roues', 'Réunion pour organisation foire au 2 roues qui auralieu de 21 mars 2020', '2018-06-01 00:01:36', '2018-06-01 00:35:07', 1, '2018-06-01 02:14:44', 1,
(4, 'Annulation du roulage Alés fin d\'année', 'Attention le roulage qui devait avoir lieu à Ales en fin d\'année est annulé car le circuit est fermé suite au record du circuit battu par Yann', '2019-01-22 18:00:00', '2018-06-01 00:01:36', 1, NULL, NULL),
(5, 'Essai de la nouvelle R1 à Barcelone', 'Essai de la nouvelle R1 à Barcelone sous la pluie', '2019-11-22 16:08:00', '2019-06-01 16:08:00', 1, NULL, NULL),
(6, 'Soirée mousse chez Fred', 'Soirée mousse chez Fred avec DJ Fred et Arnold T', '2019-12-02 19:24:16', '2019-06-01 16:08:00', 1, NULL, NULL);

INSERT INTO `events` (`id`, `title`, `description`, `event_date`, `track_id`, `organizer`, `price`, `created_on`, `created_by`, `modified_on`, `modified_by`) VALUES
(1, 'Roulage Dijon', '', '2018-07-12 00:00:00', 2, 'ActivBike', 189, '2018-06-01 09:35:07', 1, NULL, NULL),
(2, 'Roulage Vaison piste', '', '2018-08-02 00:00:00', 5, 'ActivBike', 90, '2018-02-08 14:30:29', 1, NULL, NULL),
(3, 'Journée du club à Bresse', '', '2018-08-28 00:00:00', 1, 'Team Blatz', 125, '2018-04-20 17:14:27', 1, NULL, NULL);

INSERT INTO `tracks` (`id`, `name`, `distance`, `lap_record`) VALUES
(1, 'Bresse', 3000, null),
(2, 'Dijon-Prenois', 3800, null),
(3, 'Magny-Cours', 4410, null),
(4, 'Bourbonnais', 2300, null),
(5, 'Vaison', 2000, null),
(6, 'Lédenon', 3150, null),
(7, 'Le Mans', 4190, null),
(8, 'Carole', 2055, null),
(9, 'La Ferté-Gaucher', 3600, null);
(10, 'Alès', 2500, null);

INSERT INTO `photos` (`id`, `title`, `description`, `link`, `created_on`, `modified_on`) VALUES
(1, 'Lorenzo', 'Lorenzo qui célèbre sa victoire', 'http://photos.example.com/wp-content/uploads/2018/06/IMG_1575.jpg', '2018-09-12 08:33:19', NULL),
(2, 'Marc Màrquez', 'Marc Màrquez dans le 1er virage', 'http://photos.example.com/wp-content/uploads/2018/06/IMG_1548.jpg', '2018-02-08 13:30:29', NULL),
(3, 'Johann Zarco', 'Johann Zarco', 'http://photos.example.com/wp-content/uploads/2018/06/IMG_1464.jpg', '2018-04-20 15:14:27', NULL),
(4, 'Enea Bastianini', 'Enea Bastianini', 'http://photos.example.com/wp-content/uploads/2018/06/IMG_1274.jpg', '2018-11-21 13:09:04', NULL),
(5, 'Jorge Lorenzo', 'Jorge Lorenzo', 'http://photos.example.com/wp-content/uploads/2018/06/IMG_1576', '2019-01-16 21:49:01', NULL),
(6, 'Show aérien', 'Show aérien', 'http://photos.example.com/wp-content/uploads/2018/06/IMG_1417.jpg', '2019-01-16 21:50:52', NULL),
(7, 'Marc Márquez', 'Marc Márquez', 'http://photos.example.com/wp-content/uploads/2018/06/IMG_1478.jpg', '2019-01-16 21:51:19', NULL),
(8, 'Oliveira', 'Oliveira', 'http://photos.example.com/wp-content/uploads/2018/06/IMG_1293', '2019-01-16 21:50:31', NULL),
(9, 'Départ MotoGP', 'Départ MotoGP', 'http://photos.example.com/wp-content/uploads/2018/06/IMG_1441', '2019-01-16 21:49:31', NULL),
(10, 'Cal Crutchlow', 'Cal', 'http://photos.example.com/wp-content/uploads/2018/06/IMG_1400.jpg', '2019-02-11 21:05:16', NULL);

INSERT INTO `events_members` (`id`, `event_id`, `member_id`, `created_on`) VALUES
(1, 3, 2, '2018-06-01 09:35:07'),
(2, 1, 1, '2018-02-08 14:30:29'),
(3, 3, 1, '2018-04-20 17:14:27'),
(4, 2, 1, '2017-11-18 10:42:55');

INSERT INTO `news_members` (`id`, `news_id`, `member_id`, `created_on`) VALUES
(1, 1, 2, '2018-06-01 09:35:07'),
(2, 1, 1, '2018-02-08 14:30:29'),
(3, 3, 1, '2018-04-20 17:14:27'),
(4, 4, 8, '2017-11-18 10:42:55');

INSERT INTO `news_members` (`id`, `track_id`, `member_id`, `lap_time`, `record_date`, `conditions`, `comments`, `created_on`) VALUES
(1, 1, 1, 134480, '2017-06-10', 'dry', null, '2020-04-18 21:37:17')
