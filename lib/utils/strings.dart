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

/// class that holds string constants
class AppString {

  static const String applicationTitle = 'Chachatte team';

  static const String formNotValid = 'Le formulaire n\'est pas valide. Corrigez les erreurs puis essayer à nouveau.';

  static const String cancel = 'Annuler';
  static const String save = 'Enregistrer';
  static const String confirm = 'Confirmer';
  static const String connect = 'Se connecter';
  static const String register = 'S\'inscrire';
  static const String send = 'Envoyer';

  static const String confirmation = 'Confirmation';
  static const String identification = 'Identification';
  static const String registration = 'Inscription';
  static const String askNewPassword = 'Demande de nouveau mot de passe';

  static const String about = 'A propos';
  static const String contact = 'Contact';
  static const String logout = 'Se déconnecter';

  static const String forgotPassword = 'Mot de passe oublié?';
  static const String alreadyHaveAccount = 'J\'ai déjà un compte';
  static const String loggingIn = 'Connexion en cours';
  static const String understood = 'J\'ai compris';
  static const String accountWaitingAdmin = 'Votre compte doit maintenant être validé par un administrateur avant que vous puissiez vous connecter. Vous serez averti par e-mail losrque votre compte sera actif';
  static const String forgotPasswordInfo = 'Veuillez indiquer votre adresse e-mail dans le champ ci-dessous puis cliquez sur "Envoyer", la procédure de réinitialisation de mot de passe vous sera envoyée';

  static const String tabHome = 'Accueil';
  static const String tabCalendar = 'Calendrier';
  static const String tabTeam = 'Équipe';
  static const String tabGallery = 'Gallerie';


  static const String loginEmailHint = 'Adresse e-mail';
  static const String loginPasswordHint = 'Mot de passe';
  static const String loginFailed = 'L\'dentification a échouée, vérifiez vos informations et assurez-vous que votre compte soit actif';

  static const String registrationFirstNameHint = 'Votre prénom';
  static const String registrationLastNameHint = 'Votre nom';
  static const String registrationEmailHint = 'Votre adresse e-mail';
  static const String registrationPasswordHint = 'Choisissez un mot de passe';
  static const String registrationPasswordConfirmHint = 'Confirmez votre mot de passe';

  static const String newsCreate = 'Ajouter une actualité';
  static const String newsCreated = 'L\'actualité à été créée avec succès !';
  static const String newsCreationFailed = 'Echec lors de la création de l\'actualité';
  static const String newsUpdated = 'L\'actualité à été mise à jour avec succès !';
  static const String newsUpdateFailed = 'Echec lors de la mise à jour de l\'actualité';
  static const String newsDeleted = 'L\'actualité à été supprimé avec succès !';
  static const String newsDeletionFailed = 'Echec lors de la suppression de l\'actualité';
  static const String newsDeletionAreYouSure = 'Etes-vous sûr de vouloir supprimer cette actualité ?';
  static const String newsTitle = 'Titre';
  static const String newsTitleHint = 'Saisissez le titre de l\'actualité';
  static const String newsTitleMandatory = 'Le titre est obligatoire';
  static const String newsContent = 'Contenu';
  static const String newsContentHint = 'Saisissez le contenu de l\'actualité';
  static const String newsContentMandatory = 'Le contenu est obligatoire';
  static const String newsDate = 'Date';
  static const String newsDateHint = 'JJ/MM/AAAA';
  static const String newsDateMandatory = 'La date est obligatoire';
  static const String newsDateNotValid = 'La date indiquée n\'est pas valide';
  static const String newsLikeFailed = 'Erreur, impossible d\'aimer cette actualité';

  static const String memberScreenTitle = 'Équipe';
  static const String memberCreate = 'Ajouter un membre';
  static const String memberCreated = 'Le membre à été créée avec succès !';
  static const String memberCreationFailed = 'Echec lors de la création du membre';
  static const String memberUpdated = 'Le membre à été mise à jour avec succès !';
  static const String memberUpdateFailed = 'Echec lors de la mise à jour du membre';
  static const String memberDeleted = 'Le membre à été supprimé avec succès !';
  static const String memberDeletionFailed = 'Echec lors de la suppression du membre';
  static const String memberDeletionAreYouSure = 'Etes-vous sûr de vouloir supprimer ce membre ?';
  static const String memberFirstName = 'Prénom';
  static const String memberFirstNameHint = 'Prénom du membre';
  static const String memberFirstNameMandatory = 'Le prénom est obligatoire';
  static const String memberLastName = 'Nom';
  static const String memberLastNameHint = 'Nom du membre';
  static const String memberLastNameMandatory = 'Le nom est obligatoire';
  static const String memberEmail = 'E-mail';
  static const String memberEmailHint = 'Adresse e-mail du membre';
  static const String memberEmailMandatory = 'L\'adresse e-mail est obligatoire';
  static const String memberEmailNotValid = 'L\'adresse e-mail indiquée n\'est pas valide';
  static const String memberPhone = 'Téléphone';
  static const String memberPhoneHint = 'Numéro de téléphone du membre';
  static const String memberPhoneMandatory = 'Le numéro de téléphone est obligatoire';
  static const String memberPhoneNotValid = 'Le numéro de téléphone indiqué n\'est pas valide';
  static const String memberBike = 'Moto';
  static const String memberBikeHint = 'Moto du membre';
  static const String memberBikeMandatory = 'La moto est obligatoire';
  static const String memberRegistrationDate = 'Date d\'inscription';
  static const String memberRegistrationDateHint = 'Date d\'inscription du membre';
  static const String memberRegistrationDateMandatory = 'La date d\'inscription est obligatoire';
  static const String memberRegistrationDateNotValid = 'La date indiquée n\'est pas valide';
  static const String memberActive = 'Actif ?';
  static const String memberPasswordMandatory = 'Le mot de passe est obligatoire';
  static const String memberLoginFailed = 'Connexion impossible, vérifiez vos informations et assurez-vous que votre compte est actif';

  static const String eventScreenTitle = 'Calendrier';
  static const String eventCreate = 'Ajouter un événement';
  static const String eventCreated = 'L\'événement à été créée avec succès !';
  static const String eventCreationFailed = 'Echec lors de la création de l\'événement';
  static const String eventUpdated = 'L\'événement à été mise à jour avec succès !';
  static const String eventUpdateFailed = 'Echec lors de la mise à jour de l\'événement';
  static const String eventDeleted = 'L\'événement à été supprimé avec succès !';
  static const String eventDeletionFailed = 'Echec lors de la suppression de l\'événement';
  static const String eventDeletionAreYouSure = 'Etes-vous sûr de vouloir supprimer cet événement ?';
  static const String eventTitle = 'Titre';
  static const String eventTitleHint = 'Titre de l\'événement';
  static const String eventTitleMandatory = 'Le titre est obligatoire';
  static const String eventDescription = 'Description';
  static const String eventDescriptionHint = 'Description de l\'événement';
  static const String eventDescriptionMandatory = 'La description est obligatoire';
  static const String eventPrice = 'Prix';
  static const String eventPriceHint = 'Prix de l\'événement';
  static const String eventPriceMandatory = 'Le prix est obligatoire';
  static const String eventPriceNotValid = 'Le prix indiqué n\'est pas valide';
  static const String eventTrackId = 'Circuit';
  static const String eventTrackIdHint = 'Circuit';
  static const String eventTrackIdMandatory = 'Le circuit est obligatoire';
  static const String eventTrackIdNotValid = 'Le circuit indiqué n\'est pas valide';
  static const String eventOrganizer = 'Organisateur';
  static const String eventOrganizerHint = 'Organisateur de l\'événement';
  static const String eventOrganizerMandatory = 'L\'organisateur est obligatoire';
  static const String eventDate = 'Date';
  static const String eventDateHint = 'Date de l\'événement';
  static const String eventDateMandatory = 'La date est obligatoire';
  static const String eventDateNotValid = 'La date indiquée n\'est pas valide';
  static const String eventDisplay2ItemsTooltip = 'Afficher 2 événements par ligne';
  static const String eventDisplay3ItemsTooltip = 'Afficher 3 événements par ligne';
  static const String eventDisplay4ItemsTooltip = 'Afficher 4 événements par ligne';
  static const String eventDisplay6ItemsTooltip = 'Afficher 6 événements par ligne';
  static const String eventDetailScreenTitle = 'Détail de l\'événement';

  static const String photoScreenTitle = 'Gallerie';
  static const String photoCreate = 'Ajouter une photo';
  static const String photoCreated = 'La photo à été créée avec succès !';
  static const String photoCreationFailed = 'Echec lors de la création de la photo';
  static const String photoUpdated = 'La photo à été mise à jour avec succès !';
  static const String photoUpdateFailed = 'Echec lors de la mise à jour de la photo';
  static const String photoDeleted = 'La photo à été supprimé avec succès !';
  static const String photoDeletionFailed = 'Echec lors de la suppression de la photo';
  static const String photoDeletionAreYouSure = 'Etes-vous sûr de vouloir supprimer cette photo ?';
  static const String photoTitle = 'Titre';
  static const String photoTitleHint = 'Titre de la photo';
  static const String photoTitleMandatory = 'Le titre est obligatoire';
  static const String photoDescription = 'Description';
  static const String photoDescriptionHint = 'Description de la photo';
  static const String photoDescriptionMandatory = 'La description est obligatoire';
  static const String photoLink = 'Lien';
  static const String photoLinkHint = 'Lien de la photo';
  static const String photoLinkMandatory = 'Le lien de la photo est obligatoire';

  static const String participant = 'participant';
  static const String participants = 'participants';

}