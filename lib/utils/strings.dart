/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

/// Class that holds string constants
class AppString {
  /// Format the specified [source] string according to the given [arguments].
  /// Parameters in the source string must be numbered in the format {x} starting from 0.
  /// Example : format('Hello {0}, your preferred color is {1}.', ['Bob', 'purple'])
  static format(String source, List<dynamic> arguments) {
    int index = 0;
    arguments.forEach(
      (element) => source = source.replaceFirst("{${index++}}", element != null ? element.toString() : "null"),
    );
    return source;
  }

  static const String applicationTitle = 'CCTeam';

  static const String formNotValid = 'Le formulaire n\'est pas valide. Corrigez les erreurs puis essayer à nouveau.';

  static const String error = 'Erreur';
  static const String warning = 'Attention';
  static const String info = 'Information';
  static const String success = 'Succès';
  static const String back = 'Retour';
  static const String cancel = 'Annuler';
  static const String save = 'Enregistrer';
  static const String confirm = 'Confirmer';
  static const String connect = 'Se connecter';
  static const String register = 'S\'inscrire';
  static const String send = 'Envoyer';
  static const String validate = 'Valider';
  static const String share = 'Partager';
  static const String like = 'J\'aime';
  static const String unlike = 'Je n\'aime plus';
  static const String continue1 = 'Continuer';
  static const String resendOtp = 'Renvoyer';
  static const String verify = 'Vérifier';
  static const String finish = 'Terminer';
  static const String createAccount = 'Créer un compte';
  static const String enterPasscode = 'Saisissez votre passcode';
  static const String createYourPasscode = 'Création de votre passcode';
  static const String useAnotherEmailAddress = 'Utiliser une autre adresse e-mail';
  static const String emailAddressVerification = 'Vérification de l\'adresse e-mail';
  static const String codeNotReceived = 'Code non reçu ?';
  static const String contentNotLoaded = 'Le contenu n\'a pas pu être chargé';
  static const String noContentToDisplay = 'Aucun contenu à afficher';
  static const String contentReservedForMembers = 'This content is available only for members';

  static const String notDefined = 'Non-défini';
  static const String confirmation = 'Confirmation';
  static const String identification = 'Identification';
  static const String registration = 'Inscription';
  static const String askNewPassword = 'Demande de nouveau mot de passe';
  static const String infoLoginEmail =
      'Pour vous connecter, indiquez l\'adresse e-mail liée à votre compte. Si vous n\'avez pas de compte, vous devez en créer un.';
  static const String infoRegister =
      'Complétez le formulaire ci-dessous pour commencer le processus d\'inscription. Un code vous sera envoyé afin de vérifier votre adresse e-mail.';
  static const String infoLoginOtp = 'Indiquez le code qui vous a été envoyé à l\'adresse';
  static const String timeLeft = 'Temps restant';
  static const String passcodeInfo = 'Veuillez définir un code vous permettant de sécuriser votre compte';
  static const String confirmPasscodeInfo = 'Veuillez confirmer le code';

  static const String about = 'A propos';
  static const String contact = 'Contact';
  static const String logout = 'Se déconnecter';
  static const String galleries = 'Galleries';

  static const String emailTitle = 'Adresse e-mail';
  static const String forgotPassword = 'Mot de passe oublié?';
  static const String alreadyHaveAccount = 'J\'ai déjà un compte';
  static const String loggingIn = 'Connexion en cours';
  static const String understood = 'J\'ai compris';
  static const String accountWaitingAdmin =
      'Votre compte doit maintenant être validé par un administrateur avant que vous puissiez vous connecter. Vous serez averti par e-mail losrque votre compte sera actif';
  static const String forgotPasswordInfo =
      'Veuillez indiquer votre adresse e-mail dans le champ ci-dessous puis cliquez sur "Envoyer", la procédure de réinitialisation de mot de passe vous sera envoyée';

  static const String tabHome = 'Accueil';
  static const String tabCalendar = 'Calendrier';
  static const String tabTeam = 'Équipe';
  static const String tabTracks = 'Circuits';
  static const String tabGallery = 'Gallerie';

  static const String loginEmailHint = 'Adresse e-mail';
  static const String loginOtpHint = 'Code';
  static const String loginOtpMandatory = 'Veuillez saisir le code à 6 chiffres reçu par e-mail';
  static const String loginPasswordHint = 'Mot de passe';
  static const String loginFailed =
      'L\'dentification a échouée, vérifiez vos informations et assurez-vous que votre compte soit actif';
  static const String loginNoAccountFound = "Aucun compte trouvé avec l'adresse e-mail spécifiée";
  static const String loginAccountEmailAlreadyExist = "Un compte existe déjà avec cette adresse e-mail";
  static const String loginEmailMissing = "L'adresse e-mail doit être spécifiée";

  static const String checkAccountUnexpectedResponse =
      "Une erreur inattendue est survenue lors de la vérification de votre compte. Si le problème persite, contactez un administrateur";
  static const String checkAccountError =
      "Une erreur inattendue est survenue lors de la vérification de votre compte. Si le problème persite, contactez un administrateur";

  static const String preRegisterConfirmationEmailNotSent =
      "Le code de confirmation n\'a pas pu être envoyé à l'adresse {0}. Veuillez vérifier que l\'adresse e-mail est correcte puis renvoyez le code";
  static const String preRegisterUnexpectedResponse =
      "Une erreur inattendue est survenue lors de la création de votre compte. Si le problème persite, contactez un administrateur";
  static const String preRegisterMissingData =
      "Des données sont manquantes, vérifiez que vous avez bien rempli tous les champs obligatoires. Si le problème persite, contactez un administrateur";
  static const String preRegisterError =
      "Une erreur inattendue est survenue lors de la création de votre compte. Si le problème persite, contactez un administrateur";

  static const String resendOtpMissingData =
      "Des données sont manquantes, vérifiez que vous avez bien rempli tous les champs obligatoires. Si le problème persite, contactez un administrateur";
  static const String resendOtpNoAccountFound = "Aucun compte trouvé avec l'adresse e-mail spécifiée";
  static const String resendOtpEmailNotSent =
      "Le code de confirmation n\'a pas pu être envoyé à l'adresse {0}. Veuillez vérifier que l\'adresse e-mail est correcte puis renvoyez le code";
  static const String resendOtpUnexpectedResponse =
      "Une erreur s'est produite lors de l'envoi de votre code, si le problème persite, contactez un administrateur";
  static const String resendOtpError =
      "Une erreur inattendue est survenue lors du renvoi du code. Si le problème persite, contactez un administrateur";

  static const String confirmEmailMissingData =
      "Des données sont manquantes, vérifiez que vous avez bien rempli tous les champs obligatoires. Si le problème persite, contactez un administrateur";
  static const String confirmEmailNoAccountFound = "Aucun compte trouvé avec l'adresse e-mail spécifiée";
  static const String confirmEmailOtpExpired = "Le code indiqué a expiré";
  static const String confirmEmailWrongOtp = "Le code indiqué n'est pas valide";
  static const String confirmEmailUnexpectedResponse =
      "Une erreur inattendue est survenue lors de la confirmation de votre adresse e-mail. Si le problème persite, contactez un administrateur";
  static const String confirmEmailError =
      "Une erreur inattendue est survenue lors de la confirmation de votre adresse e-mail. Si le problème persite, contactez un administrateur";

  static const String completeRegistrationMissingData =
      "Des données sont manquantes, vérifiez que vous avez bien rempli tous les champs obligatoires. Si le problème persite, contactez un administrateur";
  static const String completeRegistrationNoAccountFound = "Aucun compte trouvé avec l'adresse e-mail spécifiée";
  static const String completeRegistrationUnexpectedResponse =
      "Une erreur inattendue est survenue lors de la finalisation de votre inscription. Si le problème persite, contactez un administrateur";
  static const String completeRegistrationError =
      "Une erreur inattendue est survenue lors de la finalisation de votre inscription. Si le problème persite, contactez un administrateur";

  static const String loginMemberUnexpectedResponse =
      "Une erreur inattendue est survenue lors de la connexion à votre compte. Si le problème persite, contactez un administrateur";
  static const String loginMemberError =
      "Une erreur inattendue est survenue lors de la connexion à votre compte. Si le problème persite, contactez un administrateur";

  static const String codeHint = 'Code';
  static const String codeMandatory = 'Le code est obligatoire';

  static const String registrationFirstNameHint = 'Votre prénom';
  static const String registrationLastNameHint = 'Votre nom';
  static const String registrationEmailHint = 'Votre adresse e-mail';
  static const String registrationPasswordHint = 'Choisissez un mot de passe';
  static const String registrationPasswordConfirmHint = 'Confirmez votre mot de passe';

  static const String profileEdit = 'Modification de profil';

  static const String newsCreate = 'Ajouter une actualité';
  static const String newsCreated = 'L\'actualité à été créée avec succès !';
  static const String newsCreationFailed = 'Echec lors de la création de l\'actualité';
  static const String newsEdit = 'Modifier une actualité';
  static const String newsUpdated = 'L\'actualité à été mise à jour avec succès !';
  static const String newsUpdateFailed = 'Echec lors de la mise à jour de l\'actualité';
  static const String newsDeleted = 'L\'actualité à été supprimé avec succès !';
  static const String newsDeletionFailed = 'Echec lors de la suppression de l\'actualité';
  static const String newsDeletionAreYouSure = 'Etes-vous sûr de vouloir supprimer cette actualité ?';
  static const String newsTitle = 'Titre';
  static const String newsTitleHint = 'Saisissez le titre de l\'actualité';
  static const String newsTitleMandatory = 'Le titre est obligatoire';
  static const String newsCatchLine = 'Accroche';
  static const String newsCatchLineHint = 'Saisissez une phrase d\'accroche';
  static const String newsContent = 'Contenu';
  static const String newsContentHint = 'Saisissez le contenu de l\'actualité';
  static const String newsContentMandatory = 'Le contenu est obligatoire';
  static const String newsDate = 'Date';
  static const String newsDateHint = 'JJ/MM/AAAA';
  static const String newsDateMandatory = 'La date est obligatoire';
  static const String newsDateMustBeFuture = 'La date indiquée doit être supérieure à la date courante';
  static const String newsLikeFailed = 'Erreur, impossible d\'aimer cette actualité';
  static const String newsEmpty = 'Aucune actualité à afficher';

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
  static const String memberFirstNameHint = 'Prénom';
  static const String memberFirstNameMandatory = 'Le prénom est obligatoire';
  static const String memberLastName = 'Nom';
  static const String memberLastNameHint = 'Nom';
  static const String memberLastNameMandatory = 'Le nom est obligatoire';
  static const String memberEmail = 'E-mail';
  static const String memberEmailHint = 'Adresse e-mail du membre';
  static const String memberEmailMandatory = 'L\'adresse e-mail est obligatoire';
  static const String memberEmailNotValid = 'L\'adresse e-mail indiquée n\'est pas valide';
  static const String memberPhone = 'Téléphone';
  static const String memberPhoneHint = 'Numéro de téléphone du membre';
  static const String memberPhoneMandatory = 'Le numéro de téléphone est obligatoire';
  static const String memberPhoneNotValid = 'Le numéro de téléphone indiqué n\'est pas valide';
  static const String memberRiderNumber = 'Numéro de pilote';
  static const String memberRiderNumberHint = 'Numéro de pilote (ex: 46)';
  static const String memberBike = 'Moto';
  static const String memberBikeHint = 'Moto du membre';
  static const String memberBikeMandatory = 'La moto est obligatoire';
  static const String memberRegistrationDate = 'Date d\'inscription';
  static const String memberRegistrationDateHint = 'Date d\'inscription du membre';
  static const String memberRegistrationDateMandatory = 'La date d\'inscription est obligatoire';
  static const String memberRegistrationDateNotValid = 'La date indiquée n\'est pas valide';
  static const String memberActive = 'Actif ?';
  static const String memberActiveMandatory = 'Le statut du membre (actif ou non) est obligatoire';
  static const String memberRole = 'Rôle';
  static const String memberRoleUser = 'Utilisateur';
  static const String memberRoleMember = 'Membre';
  static const String memberRoleAdmin = 'Administrateur';
  static const String memberPasswordMandatory = 'Le mot de passe est obligatoire';
  static const String memberLoginFailed =
      'Connexion impossible, vérifiez vos informations et assurez-vous que votre compte est actif';
  static const String membersSearchHint = 'Nom / Prénom';
  static const String membersNotFound = 'Aucun membre trouvé';
  static const String memberNoEvent = 'Ce membre n\'a aucun roulage';
  static const String memberNoChrono = 'Ce membre n\'a aucun chrono';

  static const String myBikes = 'Mes motos';
  static const String bikeCreate = 'Ajouter une moto';
  static const String bikeEdit = 'Modifier une moto';
  static const String bikeAdded = 'La moto a été ajoutée avec succès !';
  static const String bikeUpdated = 'La moto a été mise à jour avec succès !';
  static const String bikeDeleted = 'La moto a été supprimée avec succès !';
  static const String bikeManufacturer = 'Constructeur';
  static const String bikeModel = 'Modèle';
  static const String bikeEngineSize = 'Cylindrée';
  static const String bikeYear = 'Année';
  static const String bikeManufacturerMandatory = 'Le constructeur est obligatoire';
  static const String bikeModelMandatory = 'Le modèle est obligatoire';
  static const String bikeEngineSizeMandatory = 'La cylindrée est obligatoire';
  static const String bikeYearMandatory = 'L\'année est obligatoire';
  static const String noBike = 'Aucune moto enregistrée';
  static const String bikeDeletionAreYouSure = 'Etes-vous sûr de vouloir supprimer cette moto ?';

  static const String tracksSearchHint = 'Nom du circuit';
  static const String tracksNotFound = 'Aucun circuit trouvé';
  static const String trackNoEvent = 'Ce circuit n\'a aucun roulage prévu';
  static const String trackNoChrono = 'Ce circuit n\'a aucun chrono';

  static const String avatarUploadFailed = 'Échec, la taille du fichier ne doit pas dépasser 500Ko';
  static const String avatarDeleteFailed = 'Échec de la suppression de l\'avatar';
  static const String avatarResetAreYouSure =
      'Cette action va supprimer votre photo de profil et remettre celle par défaut, êtes-vous sûr de vouloir continuer ?';

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
  static const String eventStartDate = 'Date de début';
  static const String eventEndDate = 'Date de fin';
  static const String eventStartDateHint = 'Date de début de l\'événement';
  static const String eventEndDateHint = 'Date de fin de l\'événement';
  static const String eventStartDateMandatory = 'La date de début est obligatoire';
  static const String eventEndDateMandatory = 'La date de fin est obligatoire';
  static const String eventDateNotValid = 'La date indiquée n\'est pas valide';
  static const String eventDetailScreenTitle = 'Roulage';
  static const String eventsNotFound = 'Aucun événement trouvé';
  static const String eventsNotFoundForYear = 'Aucun événement trouvé pour cette année';
  static const String eventsNotFoundForDate = 'Aucun événement trouvé pour cette date';
  static const String eventRegistered = 'Votre participation à été enregistrée !';
  static const String eventUnregistered = 'Votre participation à été annulée !';
  static const String eventParticipated = 'Je participe';
  static const String eventUnregister = 'Se désister';
  static const String joinEvent = 'S\'inscrire à un roulage';
  static const String noEventToJoin = 'Aucun roulage à venir disponible';
  static const String joinEventConfirmation = 'Voulez-vous vraiment vous inscrire à ce roulage ?';
  static const String pullToRefresh = 'Tirez vers le bas pour rafraîchir';

  static const String recordCreate = 'Ajouter un chrono';
  static const String recordEdit = 'Modifier un chrono';
  static const String recordCreated = 'Le chrono à été ajouté avec succès !';
  static const String recordCreationFailed = 'Echec lors de l\'ajout du chrono';
  static const String recordUpdated = 'Le chrono à été mis à jour avec succès !';
  static const String recordUpdateFailed = 'Echec lors de la mise à jour du chrono';
  static const String recordDeleted = 'Le chrono à été supprimé avec succès !';
  static const String recordDeletionFailed = 'Echec lors de la suppression du chrono';
  static const String recordDeletionAreYouSure = 'Etes-vous sûr de vouloir supprimer ce chrono ?';
  static const String recordDate = 'Date';
  static const String recordDateHint = 'Date du chrono';
  static const String recordDateMandatory = 'La date du chrono est obligatoire';
  static const String recordDateNotValid = 'La date du chrono n\'est pas valide';
  static const String recordLapTime = 'Chrono';
  static const String recordLapTimeHint = 'Chrono';
  static const String recordLapTimeMandatory = 'Le chrono est obligatoire';
  static const String recordLapTimeNotValid = 'Le chrono n\'est pas valide';
  static const String recordConditionLabel = 'Conditions';
  static const String recordConditionHint = 'Conditions de la piste';
  static const String recordConditionMandatory = 'La condition de la piste doit être indiquée';
  static const String recordBikeLabel = 'Moto';
  static const String recordBikeHint = 'Moto utilisée';
  static const String recordBikeMandatory = 'La moto doit être indiquée';

  // Membership fees
  static const String membershipFeeCreate = 'Ajouter une cotisation';
  static const String membershipFeeEdit = 'Modifier la cotisation';
  static const String membershipFeeSaved = 'Cotisation enregistrée avec succès';
  static const String membershipFeeSaveFailed = 'Erreur lors de l\'enregistrement de la cotisation';
  static const String membershipFeeDeleted = 'Cotisation supprimée avec succès';
  static const String membershipFeeDeleteFailed = 'Erreur lors de la suppression de la cotisation';
  static const String membershipFeeDeletionAreYouSure = 'Etes-vous sûr de vouloir supprimer cette cotisation ?';
  static const String membershipFeeYear = 'Année';
  static const String membershipFeeYearMandatory = 'Veuillez entrer une année';
  static const String membershipFeeYearNotValid = 'Veuillez entrer une année valide';
  static const String membershipFeeAmount = 'Montant (€)';
  static const String membershipFeeAmountMandatory = 'Veuillez entrer un montant';
  static const String membershipFeeAmountNotValid = 'Veuillez entrer un montant valide';
  static const String membershipFeePaid = 'Payée ?';
  static const String membershipFeePaidLabel = 'Payée';
  static const String membershipFeeUnpaidLabel = 'Non payée';

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
  static const String photosNotFound = 'Aucune photo trouvée';

  static const String participant = 'participant';
  static const String participants = 'Participants';
  static const String events = 'événements';
  static const String moto = 'Moto';
  static const String mobile = 'Mobile';
  static const String email = 'E-mail';
  static const String personalInformation = 'Informations personnelles';
  static const String rides = 'Roulages';
  static const String chronos = 'Chronos';
  static const String currentYear = 'Année courante';
  static const String byDate = 'Par date';

  // Calendar selector
  static const String today = 'Aujourd\'hui';
  static const String showAllForMonth = 'Voir tout le mois';
  static const String showAllForYear = 'Voir toute l\'année';
  static const String changePeriod = 'Changer de période';

  // Home stats panel
  static const String statsClub = 'Le club';
  static const String statsProfile = 'Moi';

  static const String changeHeaderPalette = 'Changer les couleurs du header';
  static const String headerPaletteTitle = 'Choisissez vos couleurs';
  static const String headerPaletteDefault = 'Couleurs par défaut';
  static const String memberHeaderPaletteLabel = 'Couleurs du header';
  static const String statsMembers = 'membres';
  static const String statsTracks = 'circuits';
  static const String statsMyEvents = 'roulages';
  static const String statsMyBikes = 'motos';
  static const String statsMembershipFee = 'cotisation';
  static const String statsMembershipPaid = 'Payée';
  static const String statsMembershipUnpaid = 'À payer';
  static const String statsMyKm = 'km estimés';
  static const String statsNextRide = 'Prochain roulage';
  static const String statsNextRideToday = 'C\'est aujourd\'hui !';
  static const String statsNextRideTomorrow = 'Demain';
  static const String statsNextRideInDays = 'Dans {0} jours';
  static const String statsNoUpcomingRide = 'Aucun roulage prévu — inscrivez-vous !';
  static const String description = 'Description';
  static const String noParticipant = 'Aucun participant';
  static const String profilePhoto = 'Photo de profil';
  static const String selectPhoto = 'Sélectionnez une photo';
  static const String maxAvatarSize = 'Max. 500 Ko';
  static const String avatarFormats = 'Formats JPG, GIF, PNG';
  static const String gallery = 'Gallerie';
  static const String camera = 'Appareil photo';
  static const String initProfilePhoto = 'Réinitialiser la photo de profil';
  static const String confirmSelection = 'Confirmer la sélection';
  static const String cancelSelection = 'Annuler la sélection';
  static const String removePhoto = 'Retirer la photo';
  static const String zoomAndCrop = 'Zoom et recadrage';
  static const String imageCropFailed = 'Le recadrage de l\'image a échoué : {0}';
  static const String profile = 'Profil';
  static const String myAccount = 'Mon compte';
  static const String myAccountTitle = 'Mon compte';
  static const String editMyProfile = 'Modifier mon profil';
  static const String changeMyPasscode = 'Changer mon passcode';
  static const String accountActions = 'Actions';
  static const String membershipStatus = 'Statut de la cotisation';
  static const String membershipPaidYear = 'Cotisation {0} payée';
  static const String membershipUnpaidYear = 'Cotisation {0} non payée';
  static const String membershipNoneYear = 'Aucune cotisation enregistrée pour {0}';
  static const String membershipAmount = '{0} CHF';

  // Change-passcode screen
  static const String changePasscodeTitle = 'Changer mon passcode';
  static const String changePasscodeStepCurrent = 'Saisissez votre passcode actuel';
  static const String changePasscodeStepNew = 'Choisissez votre nouveau passcode';
  static const String changePasscodeStepConfirm = 'Confirmez votre nouveau passcode';
  static const String changePasscodeSubmit = 'Valider';
  static const String changePasscodeSuccess = 'Passcode modifié avec succès';
  static const String changePasscodeErrorCurrentWrong = 'Le passcode actuel est incorrect';
  static const String changePasscodeErrorMismatch = 'La confirmation ne correspond pas au nouveau passcode';
  static const String changePasscodeErrorSame = 'Le nouveau passcode doit être différent du passcode actuel';
  static const String changePasscodeErrorNetwork = 'Une erreur est survenue, réessayez plus tard';

  static const String myTrackEvents = 'Mes roulages';
  static const String myChronos = 'Mes chronos';
  static const String upcomingEvents = 'Événements à venir';
  static const String pastEvents = 'Événements passés';
  static const String noUpcomingEvent = 'Aucun événement à venir';
  static const String noRegisteredEvent = 'Vous n\'êtes inscrit à aucun roulage';
  static const String tapPlusToJoinEvent = 'Touchez le bouton + pour vous inscrire à un roulage';

  // Help banners shown at the top of "Mes …" personal pages
  static const String myEventsHelp =
      'Retrouvez ici les roulages auxquels vous êtes inscrit. Touchez le bouton + pour vous inscrire à un nouveau roulage.';
  static const String myBikesHelp =
      'Retrouvez ici votre collection de motos. Touchez l\'étoile pour définir votre moto courante, ou le bouton + pour en ajouter une nouvelle.';
  static const String myChronosHelp =
      'Retrouvez ici vos meilleurs temps au tour, par circuit. Touchez le bouton + pour enregistrer un nouveau chrono.';
  static const String notifications = 'Notifications';
  static const String preferences = 'Préférences';
  static const String disconnect = 'Déconnexion';
  static const String news = 'Actualités';
  static const String detail = 'Détail';
  static const String all = 'Tous';
  static const String by = 'Par';
  static const String on = 'Le';
  static const String record = 'Record';
  static const String lapRecord = 'Record';
  static const String length = 'Longueur';
  static const String trackEvents = 'Roulages';
  static const String currentBike = 'Actuelle';

  static const String errorEmailNotFoundInDatabase = 'Aucune donnée n\' a été trouvé pour l\'adresse e-mail {0}';
  static const String errorTokenExpired = 'Votre session a expirée, veuillez vous reconnecter';
  static const String errorTokenNotFound = 'Votre session n\'est pas valide';
  static const String errorTokenWrongFormat = 'Votre identifiant de session n\'est pas valide';
  static const String errorBadCredentials = 'Nom d\'utilisateur ou mot de passe incorrect';
  static const String errorServerInternal =
      'Erreur interne au serveur. Si le problème persiste, contactez un administrateur';
  static const String errorServerTimeOut =
      "Impossible de contacter le serveur, vérifiez votre connection internet. Si le problème persite, contactez un administrateur";
  static const String errorUnknown = 'Erreur : {0}';
}
