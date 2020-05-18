//
//  ViewController.swift
//  iPautas
//
//  Created by Arleson Silva on 30/04/20.
//  Copyright © 2020 Arleson Silva. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var senha: UITextField!
    @IBAction func entrar(_ sender: Any) {
        if let email = email.text, email.isEmpty {
            alerta(mensagem: "Email inválido \(email)")
            return
        }
        if let senha = senha.text, senha.isEmpty {
            alerta(mensagem: "Senha inválida \(senha)")
            return
        }
        buscarUsuario()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func buscarUsuario() {
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuario")
        let predicate = NSPredicate (format:"email = %@", email.text!)
        requisicao.predicate = predicate
        do {
            let usuarios = try context.fetch(requisicao)
            if usuarios.count > 0 {
                for usuario in usuarios as! [NSManagedObject] {
                    let email: String = usuario.value(forKey: "email") as! String
                    let senha: String = usuario.value(forKey: "senha") as! String
                    if email == self.email.text {
                        if senha == self.senha.text {
                            atualizarUsuarioLogado(usuario: usuario)
                        }else {
                            alerta(mensagem: "Senha inválida")
                            return
                        }
                    }else {
                        alerta(mensagem: "Email inválido")
                        return
                    }
                }
            }else {
                alerta(mensagem: "Email não cadastrado")
                return
            }
        } catch {
            alerta(mensagem: "Erro ao buscar usuário")
            return
        }
    }
    
    func atualizarUsuarioLogado(usuario: NSManagedObject) {
        usuario.setValue("S", forKey: "login")
        do {
            try context.save()
            print("Usuario logado atualizado")
        } catch {
            print("Erro ao tentar atualizar usuario")
        }
    }
    
    func alerta(mensagem: String) {
        let alert = UIAlertController(title: "Atenção", message: "\(mensagem)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

}

