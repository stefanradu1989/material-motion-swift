/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import IndefiniteObservable
import MaterialMotionStreams

public class ModalDialogExampleViewController: UIViewController {

  override public func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
  }

  func didTap() {
    let vc = ModalDialogViewController()
    let tap = UITapGestureRecognizer()
    tap.addTarget(self, action: #selector(tapToDismiss))
    vc.view.addGestureRecognizer(tap)
    present(vc, animated: true)
  }

  func tapToDismiss() {
    dismiss(animated: true)
  }
}

class ModalDialogViewController: UIViewController {

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    transitionController.directorType = ModalDialogTransitionDirector.self

    modalPresentationStyle = .overCurrentContext
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .blue

    view.layer.cornerRadius = 5
    view.layer.shadowColor = UIColor(white: 0, alpha: 0.4).cgColor
    view.layer.shadowRadius = 5
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = .init(width: 0, height: 2)

    preferredContentSize = .init(width: 200, height: 200)
  }
}

class ModalDialogTransitionDirector: TransitionDirector {

  required init() {}

  var subscription: Subscription?
  func willBeginTransition(_ transition: Transition) {
    let size = transition.fore.preferredContentSize

    if transition.direction.read() == .forward {
      transition.fore.view.bounds = CGRect(origin: .zero, size: size)
    }

    let bounds = transition.containerView().bounds
    let backPositionY = bounds.maxY + size.height / 2
    let forePositionY = bounds.midY

    TransitionSpring(property: propertyOf(transition.fore.view).centerY,
                     back: backPositionY,
                     fore: forePositionY,
                     direction: transition.direction,
                     springSource: popSpringSource)
      .connect(with: transition.runtime)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      transition.direction.write(.backward)
    }
  }
}