import 'package:chachatte_team/main.dart';
import 'package:chachatte_team/providers/home_provider.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/news_list_provider.dart';
import 'package:chachatte_team/providers/passcode_provider.dart';
import 'package:chachatte_team/ui/main/home.dart';
import 'package:chachatte_team/ui/news/news_list.dart';
import 'package:chachatte_team/ui/unauthenticated/email_form.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//@GenerateMocks([http.Client])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("loading page is displayed until any content is loaded", (WidgetTester tester) async {
    // create app
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginProvider()),
        ],
        child: ChachatteTeamApp(),
      ),
    );

    // check that there is the loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // wait until there are no longer any frames scheduled
    await tester.pumpAndSettle();

    // check that after load, the loading indicator has disappeared
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  /// To run this test, make sure that the backend is offline to get a timeout :)
  testWidgets(
    "an error message is displayed on application load if server timeout occurs",
    (WidgetTester tester) async {
      // create app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LoginProvider()),
          ],
          child: ChachatteTeamApp(),
        ),
      );

      // wait until there are no longer any frames scheduled
      await tester.pumpAndSettle();

      // check that we are indeed in email form page
      expect(find.byType(EmailForm), findsOneWidget);

      // check that we are getting server timeout error message
      expect(find.text(AppString.errorServerTimeOut), findsOneWidget);
    },
    skip: true,
  );

  testWidgets("email form is displayed on application load if shared preferences are empty",
      (WidgetTester tester) async {
    // empty shared preferences
    SharedPreferences.setMockInitialValues({});

    // create app
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginProvider()),
        ],
        child: ChachatteTeamApp(),
      ),
    );

    // check that email and JWT or not in shared preferences
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey("email"), false);
    expect(preferences.containsKey("jwt"), false);

    // wait until there are no longer any frames scheduled
    await tester.pumpAndSettle();

    // check that we are indeed in email form page
    expect(find.text(AppString.identification), findsOneWidget);
  });

  testWidgets("an error message is displayed on application load if JWT token is not valid",
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      "email": TEST_VALID_ACCOUNT_EMAIL,
      "jwt": TEST_INVALID_JWT,
    });

    /*MockGraphQLClient mockClient = MockGraphQLClient();

    when(mockClient.query(any)).thenAnswer((_) async => QueryResult(
          data: json.decode('{"userId": 1, "id": 2, "title": "mock"}'),
          source: QueryResultSource.network,
          exception: new OperationException(),
        ));*/

    // create app
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginProvider()),
          ChangeNotifierProvider(create: (_) => PasscodeProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => NewsListProvider()),
        ],
        child: ChachatteTeamApp(),
      ),
    );

    // check shared preferences values
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.get("email"), TEST_VALID_ACCOUNT_EMAIL);
    expect(preferences.get("jwt"), TEST_INVALID_JWT);

    // wait until there are no longer any frames scheduled
    await tester.pumpAndSettle();

    // check that we are indeed in passcode form page
    expect(find.text(AppString.errorTokenWrongFormat), findsOneWidget);
  });

  testWidgets("login is successful on application load if email and JWT are valid", (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      "email": TEST_VALID_ACCOUNT_EMAIL,
      "jwt": TEST_VALID_JWT,
    });

    // create app
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginProvider()),
          ChangeNotifierProvider(create: (_) => PasscodeProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => NewsListProvider()),
        ],
        child: ChachatteTeamApp(),
      ),
    );

    // check shared preferences values
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.get("email"), TEST_VALID_ACCOUNT_EMAIL);
    expect(preferences.get("jwt"), TEST_VALID_JWT);

    // wait until there are no longer any frames scheduled
    await tester.pumpAndSettle();

    // check that we are indeed in passcode form page
    expect(find.byType(Home), findsOneWidget);
    expect(find.byType(NewsList), findsOneWidget);
  });

  testWidgets("Test login form page", (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      "email": TEST_VALID_ACCOUNT_EMAIL,
      "jwt": TEST_INVALID_JWT,
    });

    // create app
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginProvider()),
          ChangeNotifierProvider(create: (_) => PasscodeProvider()),
        ],
        child: ChachatteTeamApp(),
      ),
    );

    // wait until there are no longer any frames scheduled
    await tester.pumpAndSettle();

    // check that we are indeed in email form page
    expect(find.text(AppString.identification), findsOneWidget);

    // check that email text field exists and is unique
    final loginEmailFieldFinder = find.byKey(Key('loginEmailField'));
    expect(loginEmailFieldFinder, findsOneWidget);

    // retrieve TextFormField Widget
    final TextFormField loginEmailField = tester.widget(loginEmailFieldFinder);

    // check that e-mail text field is empty
    expect(loginEmailField.initialValue, isEmpty);

    // check that continue button exists and is unique
    final emailContinueButtonFinder = find.byKey(Key('emailContinueButton'));
    expect(emailContinueButtonFinder, findsOneWidget);

    // tap continue button
    await tester.tap(emailContinueButtonFinder);
    await tester.pumpAndSettle();

    // expect to receive field validation error
    expect(find.text(AppString.memberEmailMandatory), findsOneWidget);

    // enter an invalid e-mail address
    await tester.enterText(loginEmailFieldFinder, TEST_INVALID_EMAIL);

    // check that text field contains text
    expect(find.text(TEST_INVALID_EMAIL), findsOneWidget);

    // tap continue button
    await tester.tap(emailContinueButtonFinder);
    await tester.pumpAndSettle();

    // expect to receive field validation error
    expect(find.text(AppString.memberEmailNotValid), findsOneWidget);

    // enter a valid e-mail address but with no existing account
    await tester.enterText(loginEmailFieldFinder, TEST_VALID_NO_ACCOUNT_EMAIL);

    // check that text field contains text
    expect(find.text(TEST_VALID_NO_ACCOUNT_EMAIL), findsOneWidget);

    // tap continue button
    await tester.tap(emailContinueButtonFinder);
    await tester.pumpAndSettle();

    // check that we error message is raised
    expect(find.text(AppString.loginNoAccountFound), findsOneWidget);

    // enter a valid e-mail address but with no existing account
    await tester.enterText(loginEmailFieldFinder, TEST_VALID_ACCOUNT_EMAIL);

    // check that text field contains text
    expect(find.text(TEST_VALID_ACCOUNT_EMAIL), findsOneWidget);

    // tap continue button
    await tester.tap(emailContinueButtonFinder);
    await tester.pumpAndSettle();

    // check that we are on passcode form
    expect(find.text(AppString.enterPasscode), findsOneWidget);

    // check that use another email button exists and is unique
    final useAnotherEmailAddressButtonFinder = find.byKey(Key('useAnotherEmailAddressButton'));
    expect(useAnotherEmailAddressButtonFinder, findsOneWidget);

    // tap use another email button
    await tester.tap(useAnotherEmailAddressButtonFinder);
    await tester.pumpAndSettle();

    // check that we are back on email form page
    expect(find.text(AppString.identification), findsOneWidget);

    // check that create account button exists and is unique
    final createAccountButtonFinder = find.byKey(Key('createAccountButton'));
    expect(createAccountButtonFinder, findsOneWidget);

    // tap create account button
    await tester.tap(createAccountButtonFinder);
    await tester.pumpAndSettle();

    // check that we are on account creation form
    expect(find.text(AppString.registration), findsOneWidget);
  });

  testWidgets("Test create account page", (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      "email": TEST_VALID_ACCOUNT_EMAIL,
      "jwt": TEST_INVALID_JWT,
    });

    // create app
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginProvider()),
        ],
        child: ChachatteTeamApp(),
      ),
    );

    // check that there is the loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // wait until there are no longer any frames scheduled
    await tester.pumpAndSettle();

    // check that we are in email form page
    expect(find.text(AppString.identification), findsOneWidget);

    // check that create account button exists and is unique
    final createAccountButtonFinder = find.byKey(Key('createAccountButton'));
    expect(createAccountButtonFinder, findsOneWidget);

    // tap create account button
    await tester.tap(createAccountButtonFinder);
    await tester.pumpAndSettle();

    // check that we are on account creation form
    expect(find.text(AppString.registration), findsOneWidget);

    // check that form fields exist
    final registerFormFirstNameFieldFinder = find.byKey(Key('registerFormFirstNameField'));
    expect(registerFormFirstNameFieldFinder, findsOneWidget);
    final registerFormLastNameFieldFinder = find.byKey(Key('registerFormLastNameField'));
    expect(registerFormLastNameFieldFinder, findsOneWidget);
    final registerFormEmailFieldFinder = find.byKey(Key('registerFormEmailField'));
    expect(registerFormEmailFieldFinder, findsOneWidget);

    // check that register button exists and is unique
    final registerFormRegisterButtonFinder = find.byKey(Key('registerFormRegisterButton'));
    expect(registerFormRegisterButtonFinder, findsOneWidget);

    // tap register button
    await tester.tap(registerFormRegisterButtonFinder);
    await tester.pumpAndSettle();

    // expect to receive field validation error
    expect(find.text(AppString.memberFirstNameMandatory), findsOneWidget);
    expect(find.text(AppString.memberLastNameMandatory), findsOneWidget);
    expect(find.text(AppString.memberEmailMandatory), findsOneWidget);

    // enter information with invalid email
    await tester.enterText(registerFormFirstNameFieldFinder, TEST_USER_FIRST_NAME);
    await tester.enterText(registerFormLastNameFieldFinder, TEST_USER_LAST_NAME);
    await tester.enterText(registerFormEmailFieldFinder, TEST_INVALID_EMAIL);

    // tap register button
    await tester.tap(registerFormRegisterButtonFinder);
    await tester.pumpAndSettle();

    // expect invalid email validation error
    expect(find.text(AppString.memberEmailNotValid), findsOneWidget);

    // enter a valid e-mail address but with already existing account
    await tester.enterText(registerFormEmailFieldFinder, TEST_VALID_ACCOUNT_EMAIL);

    // tap register button
    await tester.tap(registerFormRegisterButtonFinder);
    await tester.pumpAndSettle();

    // expect account already exist validation email
    expect(find.text(AppString.loginAccountEmailAlreadyExist), findsOneWidget);

    // enter a valid e-mail address which does not match an existing account
    await tester.enterText(registerFormEmailFieldFinder, TEST_VALID_NO_ACCOUNT_EMAIL);
  });
}
