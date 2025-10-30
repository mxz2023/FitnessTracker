/**
 * 健康监测应用主页面
 */
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';

import { CommonDefine } from '../common/CommonDefine';
import { HealthOverview } from '../views/HealthOverview';
import { logger } from '../utils/Logger';

@Entry
@Component
struct Index {
  private pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    AppStorage.setOrCreate(CommonDefine.globalPathStackName, this.pathStack);

    this.loginWithHuaweiID();
  }

  build() {
    Navigation(this.pathStack) {
      HealthOverview()
    }
    .title($r('app.string.app_name'))
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .width('100%')
    .height('100%')
  }

  /**
   * Sample code for using HUAWEI ID to log in to atomic service.
   * According to the Atomic Service Review Guide, when a atomic service has an account system,
   * the option to log in with a HUAWEI ID must be provided.
   * The following presets the atomic service to use the HUAWEI ID silent login function.
   * To enable the atomic service to log in successfully using the HUAWEI ID, please refer
   * to the HarmonyOS HUAWEI ID Access Guide to configure the client ID and fingerprint certificate.
   */
  private loginWithHuaweiID() {
    // Create a login request and set parameters
    const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    // Whether to forcibly launch the HUAWEI ID login page when the user is not logged in with the HUAWEI ID
    loginRequest.forceLogin = false;
    // Execute login request
    const controller = new authentication.AuthenticationController();
    controller.executeRequest(loginRequest).then((data) => {
      const loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
      const authCode = loginWithHuaweiIDResponse.data?.authorizationCode;
      // Send authCode to the backend in exchange for unionID, session

    }).catch((error: BusinessError) => {
      logger.error("testTag", 'error: %{public}s', JSON.stringify(error))
      if (error.code === authentication.AuthenticationErrorCode.ACCOUNT_NOT_LOGGED_IN) {
        // HUAWEI ID is not logged in, it is recommended to jump to the login guide page

      }
    });
  }
}