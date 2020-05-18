//
//  CadastroUsuarioViewController.swift
//  iPautas
//
//  Created by Arleson Silva on 30/04/20.
//  Copyright © 2020 Arleson Silva. All rights reserved.
//

import UIKit
import CoreData

class CadastroUsuarioViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var nome: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var senha: UITextField!
    
    @IBAction func cadastrar(_ sender: Any) {
        if let nome = nome.text, nome.isEmpty {
            alerta(mensagem: "Nome nao esta ok \(nome)")
            return
        }
        if let email = email.text, email.isEmpty {
            alerta(mensagem: "Email nao esta ok \(email)")
            return
        }
        if let senha = senha.text, senha.isEmpty {
            alerta(mensagem: "Senha nao esta ok \(senha)")
            return
        }
        if verificaSeEmailJaCadastrado() {
            alerta(mensagem: "Email já existe em nossa base de dados")
            return
        }
        cadastrarUsuario()
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
    
    func verificaSeEmailJaCadastrado() -> Bool {
        let predicate = NSPredicate (format:"email = %@" ,email.text!)
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuario")
        requisicao.predicate = predicate
        do {
            let usuarios = try context.fetch(requisicao)
            if usuarios.count > 0 {
                return true
            }else {
                return false
            }
        } catch {
            alerta(mensagem: "Erro ao buscar usuário")
            return false
        }
    }
    
    func cadastrarUsuario() {
        let usuario = NSEntityDescription.insertNewObject(forEntityName: "Usuario", into: context)
        usuario.setValue(nome.text, forKey: "nome")
        usuario.setValue(email.text, forKey: "email")
        usuario.setValue(senha.text, forKey: "senha")
        usuario.setValue("N", forKey: "login")
        do {
            try context.save()
            alerta(mensagem: "Usuário salvo com sucesso")
        } catch let erro as Error {
            alerta(mensagem: "Erro ao salvar usuário: \(erro.localizedDescription)")
        }
    }
    
    func alerta(mensagem: String) {
        let alert = UIAlertController(title: "Atenção", message: "\(mensagem)", preferredStyle: .alert)
        if mensagem == "Usuário salvo com sucesso" {
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                self.navigationController?.popViewController(animated: true)
            }))
        }else {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

}

