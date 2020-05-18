//
//  AdicionarPautaViewController.swift
//  iPautas
//
//  Created by Arleson Silva on 03/05/20.
//  Copyright © 2020 Arleson Silva. All rights reserved.
//

import UIKit
import CoreData

class AdicionarPautaViewController: UIViewController, UITextViewDelegate {

    var context: NSManagedObjectContext!
    var email: String!
    var codigo: Int = 0
    var vtitulo: Bool = false
    var vdescricao: Bool = false
    var vdetalhe: Bool = false
    
    @IBOutlet weak var titulo: UITextField!
    @IBOutlet weak var descricao: UITextView!
    @IBOutlet weak var detalhe: UITextField!
    @IBOutlet weak var autor: UILabel!
    @IBOutlet weak var finalizar: UIButton!
    
    @IBAction func salvar(_ sender: Any) {
        if let titulo = titulo.text, titulo.isEmpty {
            alerta(mensagem: "Título inválido \(titulo)")
            return
        }
        if let descricao = descricao.text, descricao.isEmpty {
            alerta(mensagem: "Título inválido \(descricao)")
            return
        }
        if let detalhe = detalhe.text, detalhe.isEmpty {
            alerta(mensagem: "Título inválido \(detalhe)")
            return
        }
        cadastrarPauta()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate
        
        context = appDelegate.persistentContainer.viewContext
            
        descricao.delegate = (self as UITextViewDelegate)
        titulo.addTarget(self, action: #selector(myTargetFunction), for: .editingChanged)
        detalhe.addTarget(self, action: #selector(myTargetFunction), for: .editingChanged)
        
        descricao.text = "Digite aqui uma descrição para a pauta"
        descricao.textColor = UIColor.lightGray
        
        //descricao.delegate = self
        descricao.text = "Digite a descrição da pauta"
        descricao.textColor = UIColor.lightGray
        
        buscarInfoUsuarioLogado()
        buscarUltimoCodigoPautaInserido()
        verificaSeHabilitaBtnFinalizar()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descricao.textColor == UIColor.lightGray {
            descricao.text = ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let descricao = descricao.text, descricao.count > 0 {
            vdescricao = true
        }else {
            vdescricao = false
        }
        verificaSeHabilitaBtnFinalizar()
    }
    
    @objc func myTargetFunction(textField: UITextField) {
        if let titulo = titulo.text, titulo.count > 0 {
            vtitulo = true
        }else {
            vtitulo = false
        }
        if let detalhe = detalhe.text, detalhe.count > 0 {
            vdetalhe = true
        }else {
            vdetalhe = false
        }
        verificaSeHabilitaBtnFinalizar()
    }
    
    func verificaSeHabilitaBtnFinalizar() {
        if vtitulo && vdescricao && vdetalhe {
            finalizar.isEnabled = true
        }else {
            finalizar.isEnabled = false
        }
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
                        email = (data.value(forKey: "email") as! String)
                        autor.text = "Criado por: \(data.value(forKey: "nome") as! String)"
                    }
                }
            }
        } catch {
            alerta(mensagem: "Falha ao tentar buscar informações do usuário logado")
        }
    }
    
    func buscarUltimoCodigoPautaInserido() {
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Pauta")
        do {
            let result = try context.fetch(requisicao)
            if result.count > 0 {
                codigo = result.count + 1
                print(codigo)
            }else {
                codigo = 1
                print(codigo)
            }
        } catch {
            alerta(mensagem: "Falha ao tentar buscar informações do usuário logado")
        }
    }
    
    func cadastrarPauta() {
        let pauta = NSEntityDescription.insertNewObject(forEntityName: "Pauta", into: context)
        pauta.setValue(codigo, forKey: "codigo")
        pauta.setValue(titulo.text, forKey: "titulo")
        pauta.setValue(descricao.text, forKey: "descricao")
        pauta.setValue(detalhe.text, forKey: "detalhe")
        pauta.setValue(email, forKey: "email_autor")
        pauta.setValue("Aberto", forKey: "status") //Aberto //Fechado
        do {
            try context.save()
            alerta(mensagem: "Pauta salvo com sucesso")
        } catch let erro as Error? {
            alerta(mensagem: "Erro ao salvar pauta: \(erro!.localizedDescription)")
        }
    }
    
    
    func alerta(mensagem: String) {
        let alert = UIAlertController(title: "Atenção", message: "\(mensagem)", preferredStyle: .alert)
        if mensagem == "Pauta salvo com sucesso" {
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
