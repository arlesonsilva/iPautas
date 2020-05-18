//
//  EsqueciMinhaSenhaViewController.swift
//  iPautas
//
//  Created by Arleson Silva on 02/05/20.
//  Copyright © 2020 Arleson Silva. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class EsqueciMinhaSenhaViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var email: UITextField!
    @IBAction func enviarEmail(_ sender: Any) {
        if let email = email.text, email.isEmpty {
            alerta(mensagem: "Email inválido")
            return
        }
        verificaSeEmailJaCadastrado()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func verificaSeEmailJaCadastrado() {
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuario")
        let predicate = NSPredicate (format:"email = %@" ,email.text!)
        requisicao.predicate = predicate
        do {
            let usuarios = try context.fetch(requisicao)
            if usuarios.count > 0 {
                for usuario in usuarios as! [NSManagedObject] {
                    let nome: String = usuario.value(forKey: "nome") as! String
                    let email: String = usuario.value(forKey: "email") as! String
                    let senha: String = usuario.value(forKey: "senha") as! String
                    sendEmail(email: email, nome: nome, senha: senha)
                }
            }else {
                alerta(mensagem: "Não existe cadastrado com este email \(email.text!)")
                return
            }
        } catch {
            alerta(mensagem: "Erro ao buscar usuário")
            return
        }
    }
    
    func sendEmail(email: String, nome: String, senha: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
            mail.setToRecipients([email])
            mail.setSubject("Senha de acesso ")
            mail.setMessageBody("<h1>Olá \(nome), Sua senha de acesso ao app iPautas é: \(senha).<h1>", isHTML: true)
            present(mail, animated: true)
        } else {
            alerta(mensagem: "Não foi possivél enviar o email")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
            break
        case .saved:
            print("Mail saved")
            break
        case .sent:
            print("Mail sent")
            break
        case .failed:
            print("Mail failed")
            break
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
        //controller.dismiss(animated: true)
    }
    
    
    
    func alerta(mensagem: String) {
        let alert = UIAlertController(title: "Atenção", message: "\(mensagem)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}
