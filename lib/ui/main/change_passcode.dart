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

import 'package:ccteam/providers/change_passcode_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/passcode_keypad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// In-app screen letting an authenticated member change their own
/// passcode. Three local steps share a single keypad, the title and
/// description swap as the user progresses. The active buffer auto-
/// advances on the 6th digit; the final step requires a "Valider" tap.
class ChangePasscode extends StatefulWidget {
  const ChangePasscode({Key? key}) : super(key: key);

  @override
  State<ChangePasscode> createState() => _ChangePasscodeState();
}

class _ChangePasscodeState extends State<ChangePasscode> {
  @override
  void initState() {
    super.initState();
    // wipe any leftover state from a previous (cancelled) attempt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChangePasscodeProvider>(context, listen: false).reset();
    });
  }

  /// Map the step to the matching label (title under the AppBar).
  String _titleForStep(ChangePasscodeStep step) {
    switch (step) {
      case ChangePasscodeStep.enterCurrent:
        return AppString.changePasscodeStepCurrent;
      case ChangePasscodeStep.enterNew:
        return AppString.changePasscodeStepNew;
      case ChangePasscodeStep.confirmNew:
        return AppString.changePasscodeStepConfirm;
    }
  }

  /// Pick the buffer value for [step] from the provider.
  String _bufferForStep(ChangePasscodeProvider p, ChangePasscodeStep step) {
    switch (step) {
      case ChangePasscodeStep.enterCurrent:
        return p.currentBuffer;
      case ChangePasscodeStep.enterNew:
        return p.newBuffer;
      case ChangePasscodeStep.confirmNew:
        return p.confirmBuffer;
    }
  }

  /// Convert an error key from the provider into the localised
  /// message to show under the keypad.
  String? _errorMessage(String? key) {
    switch (key) {
      case "current_wrong":
        return AppString.changePasscodeErrorCurrentWrong;
      case "new_mismatch":
        return AppString.changePasscodeErrorMismatch;
      case "same_passcode":
        return AppString.changePasscodeErrorSame;
      case "network":
        return AppString.changePasscodeErrorNetwork;
      default:
        return null;
    }
  }

  /// Build the step-indicator row at the top, three small dots, the
  /// active one is bigger and filled. Visual progress without taking
  /// vertical space away from the keypad.
  Widget _buildStepIndicator(ChangePasscodeStep currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (final step in ChangePasscodeStep.values) ...[
          _buildStepDot(step == currentStep, _isStepDone(step, currentStep)),
          if (step != ChangePasscodeStep.confirmNew)
            Container(width: 24, height: 1.5, color: Colors.blue[900]!.withValues(alpha: 0.4)),
        ],
      ],
    );
  }

  bool _isStepDone(ChangePasscodeStep step, ChangePasscodeStep current) {
    return step.index < current.index;
  }

  Widget _buildStepDot(bool active, bool done) {
    return Container(
      width: active ? 14 : 10,
      height: active ? 14 : 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active || done ? Colors.blue[700] : Colors.transparent,
        border: Border.all(color: Colors.blue[900]!, width: 1.5),
      ),
    );
  }

  Future<void> _onSubmit(ChangePasscodeProvider provider) async {
    final bool ok = await provider.submit();
    if (!mounted) return;
    if (ok) {
      Provider.of<MessageProvider>(
        context,
        listen: false,
      ).setMessage(AppString.changePasscodeSuccess, MessageType.SUCCESS);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChangePasscodeProvider provider = Provider.of<ChangePasscodeProvider>(context, listen: true);
    final ChangePasscodeStep step = provider.step;
    final String currentBuffer = _bufferForStep(provider, step);
    final String? errorMessage = _errorMessage(provider.errorKey);
    final bool isSubmitting = provider.loadingStatus == LoadingStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.changePasscodeTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              children: <Widget>[
                _buildStepIndicator(step),
                const SizedBox(height: 20.0),
                // step title, the only thing that changes between steps
                Text(
                  _titleForStep(step),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 8.0),
                // reserve a fixed vertical zone for the inline error so the keypad doesn't jump up/down when an error appears or disappears
                SizedBox(
                  height: 36.0,
                  child: errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[800], fontSize: 13.0, fontWeight: FontWeight.w500),
                          ),
                        )
                      : null,
                ),
                Expanded(
                  child: PasscodeKeypad(
                    value: currentBuffer,
                    enabled: !isSubmitting,
                    onChanged: (String newValue) => provider.setBuffer(step, newValue),
                    // no auto-submit on the final step, we want the user to explicitly tap Valider so they can review
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      ),
                      onPressed: (provider.canSubmit && !isSubmitting) ? () => _onSubmit(provider) : null,
                      child: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              AppString.changePasscodeSubmit,
                              style: TextStyle(color: Colors.white, fontSize: 15.0),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
