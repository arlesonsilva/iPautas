//
//  PerfilUsuarioViewController.swift
//  iPautas
//
//  Created by Arleson Silva on 03/05/20.
//  Copyright © 2020 Arleson Silva. All rights reserved.
//

import UIKit
import CoreData

class PerfilUsuarioViewController: UIViewController {
    
    var context: NSManagedObjectContext!

    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var email: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSairApp" {
            sairApp()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        buscarInfoUsuarioLogado()
    }
    
    func buscarInfoUsuarioLogado() {
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuario")
        let predicate = NSPredicate (format:"login = %@", "S")
        requisicao.predicate = predicate
        do {
            let result = try context.fetch(requisicao)
            if result.count > 0 {
                for data in result as! [NSManagedObject] {
                    if data.value(forKey: "login") as! String == "S" {
                        nome.text = (data.value(forKey: "nome") as! String)
                        email.text = (data.value(forKey: "email") as! String)
                    }
                }
            }else {
                alerta(mensagem: "Nenhum usuario logado")
                let loginPageView = self.storyboard?.instantiateViewController(withIdentifier: "LoginPageID") as! ViewController
                self.present(loginPageView, animated: true, completion: nil)
            }
        } catch {
            alerta(mensagem: "Falha ao tentar buscar informação do usuário")
        }
    }
    
    func sairApp() {
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuario")
        let predicate = NSPredicate (format:"email = %@", email.text!)
        requisicao.predicate = predicate
        do {
            let result = try context.fetch(requisicao)
            for data in result as! [NSManagedObject] {
                if data.value(forKey: "login") as! String == "S" {
                    data.setValue("N", forKey: "login")
                    do {
                        try context.save()
                        print("Usuario deslogado do app")
                    } catch {
                        alerta(mensagem: "Erro ao tentar deslogar usuário")
                    }
                }
            }
        } catch {
            alerta(mensagem: "Failha ao tentar deslogar usuário")
        }
    }
    
    func alerta(mensagem: String) {
        let alert = UIAlertController(title: "Atenção", message: "\(mensagem)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}
