//
//  SignInViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift

class SignInViewController: UIViewController {

    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let signInButton = PointButton(title: "로그인")
    let signUpButton = UIButton()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        
        bind()
        aboutCombineLatest()
        
        signUpButton.addTarget(self, action: #selector(signUpButtonClicked), for: .touchUpInside)
    }
    
    func bind() {
        
        let email = emailTextField.rx.text.orEmpty
        let password = passwordTextField.rx.text.orEmpty
        
        let validation = Observable.combineLatest(email, password) { first, second in
            return first.count > 8 && second.count >= 6
        }
        
        validation.bind(to: signInButton.rx.isEnabled).disposed(by: disposeBag)
        validation.subscribe(with: self) { owner, value in
            owner.signInButton.backgroundColor = value ? UIColor.black : UIColor.red
            owner.emailTextField.layer.borderColor = value ? UIColor.blue.cgColor : UIColor.red.cgColor
            owner.passwordTextField.layer.borderColor = value ? UIColor.blue.cgColor : UIColor.red.cgColor
        }.disposed(by: disposeBag)
        
        signInButton.rx.tap.subscribe(with: self) { owner, value in
            owner.navigationController?.pushViewController(SearchViewController(), animated: true)
        }.disposed(by: disposeBag)
    }
    
    @objc func signUpButtonClicked() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    func aboutCombineLatest() {
        let a = BehaviorSubject(value: 3)
        let b = BehaviorSubject(value: "greetings")
        Observable.combineLatest(a, b) { first, second in
            return "결과 \(first) and \(second)"
        }.subscribe(with: self) { owner, value in
            print(value)
        }.disposed(by: disposeBag)
        
        a.onNext(4)
        a.onNext(5)
        a.onNext(6)
        b.onNext("hello")
        b.onNext("world")
    }
    
    
    func configure() {
        signUpButton.setTitle("회원이 아니십니까?", for: .normal)
        signUpButton.setTitleColor(Color.black, for: .normal)
    }
    
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signInButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(signInButton.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    

}
