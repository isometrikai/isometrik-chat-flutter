import 'package:chat_component_example/controllers/controllers.dart';
import 'package:chat_component_example/res/dimens.dart';
import 'package:chat_component_example/res/res.dart';
import 'package:chat_component_example/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utilities/route_management.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static const String route = AppRoutes.login;

  @override
  Widget build(BuildContext context) {
    return GetX<AuthController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            Strings.login,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryColorLight,
          centerTitle: true,
        ),
        body: Form(
          key: controller.loginFormKey,
          child: Padding(
            padding: Dimens.edgeInsets16,
            child: Center(
              child: SizedBox(
                // alignment: Alignment.center,
                width: ResponsiveExample.isWeb(context)
                    ? Dimens.percentWidth(.3)
                    : null,
                child: Column(
                  mainAxisAlignment: ResponsiveExample.isWeb(context)
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Strings.email),
                    Dimens.boxHeight8,
                    InputField.email(controller: controller.emailController),
                    Dimens.boxHeight16,
                    Text(Strings.password),
                    Dimens.boxHeight8,
                    InputField.password(
                        suffixIcon: IconButton(
                          icon: Icon(!controller.isPassward
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () {
                            controller.isPassward = !controller.isPassward;
                          },
                        ),
                        obscureText: controller.isPassward,
                        obscureCharacter: '*',
                        controller: controller.passwordController),
                    Dimens.boxHeight32,
                    Button(
                        onTap: controller.validateLogin, label: Strings.login),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: InkWell(
                        onTap: RouteManagement.goToSignPage,
                        child: Text(
                          Strings.signUp,
                          style: const TextStyle(
                              color: AppColors.primaryColorLight),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
