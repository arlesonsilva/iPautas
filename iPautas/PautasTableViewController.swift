//
//  PautasTableViewController.swift
//  iPautas
//
//  Created by Arleson Silva on 03/05/20.
//  Copyright © 2020 Arleson Silva. All rights reserved.
//

import UIKit
import CoreData

class PautasTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext!
    var nome: String!
    
    var selectedIndex = -1
    var selectedSection = -1
    var selectedIndexPath: IndexPath!
    var isCollapse = false
    
    var pautasAbertas: [NSManagedObject] = []
    var pautasFechadas: [NSManagedObject] = []
    @IBOutlet var tableViewPauta: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        verificaSeUsuarioLogado()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recuperarPautasAberta()
        recuperarPautasFechadas()
        //tableViewPauta.rowHeight = 243
        //tableViewPauta.rowHeight = UITableView.automaticDimension
        //tableViewPauta.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Pautas Abertas"
        }else {
            return "Pautas Fechadas"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pautasAbertas.count
        }else {
            return pautasFechadas.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pauta: NSManagedObject
        if indexPath.section == 0 {
            pauta = pautasAbertas[indexPath.row]
        }else {
            pauta = pautasFechadas[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula", for: indexPath) as! PautaCelula
        cell.titulo.text = (pauta.value(forKey: "titulo") as! String)
        cell.breveDescricao.text = (pauta.value(forKey: "descricao") as! String)
        cell.descricaoCompleta.text = (pauta.value(forKey: "descricao") as! String)
        cell.autor.text = nome
        if indexPath.section == 0 {
            cell.botaoAcao.setTitle("Finalizar", for: .normal)
        }else {
            cell.botaoAcao.setTitle("Reabrir", for: .normal)
        }
        cell.botaoAcao.tag = pauta.value(forKey: "codigo") as! Int
        cell.botaoAcao.addTarget(self, action: #selector(subscribeTapped(_:)), for: .touchUpInside)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if selectedIndex == indexPath.row && isCollapse && selectedSection == indexPath.section {
                return 250
            }else {
                return 70
            }
        }else {
            if selectedIndex == indexPath.row && isCollapse && selectedSection == indexPath.section {
                return 250
            }else {
                return 70
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula", for: indexPath) as! PautaCelula
        cell.breveDescricao.isHidden = true
        
        if indexPath.section == 0 {
            if selectedIndex == indexPath.row && selectedSection == indexPath.section {
                if !isCollapse {
                    isCollapse = true
                    cell.breveDescricao.isHidden = true
                    cell.descricaoCompleta.isHidden = false
                }else{
                    isCollapse = false
                    cell.breveDescricao.isHidden = false
                    cell.descricaoCompleta.isHidden = true
                }
            }else {
                isCollapse = true
                cell.breveDescricao.isHidden = true
                cell.descricaoCompleta.isHidden = false
            }
        }else {
            if selectedIndex == indexPath.row && selectedSection == indexPath.section {
                if !isCollapse {
                    isCollapse = true
                    cell.breveDescricao.isHidden = true
                    cell.descricaoCompleta.isHidden = false
                }else{
                    isCollapse = false
                    cell.breveDescricao.isHidden = false
                    cell.descricaoCompleta.isHidden = true
                }
            }else {
                isCollapse = true
                cell.breveDescricao.isHidden = true
                cell.descricaoCompleta.isHidden = false
            }
        }
        selectedIndexPath = indexPath
        selectedSection = indexPath.section
        selectedIndex = indexPath.row
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    @objc func subscribeTapped(_ sender: UIButton){
        if !isCollapse {
            isCollapse = true
        }else{
            isCollapse = false
        }
        tableView.reloadRows(at: [self.selectedIndexPath], with: .automatic)
        atualizaPauta(codigo: sender.tag)
    }
    
    func atualizaPauta(codigo: Int) {
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Pauta")
        let predicate = NSPredicate (format:"codigo == %i", codigo)
        requisicao.predicate = predicate
        do {
            let pautas = try context.fetch(requisicao)
            if pautas.count > 0 {
                for pauta in pautas as! [NSManagedObject] {
                    let status = (pauta.value(forKey: "status") as! String)
                    if status == "Aberto" {
                        pauta.setValue("Fechado", forKey: "status")
                    }else {
                        pauta.setValue("Aberto", forKey: "status")
                    }
                    do {
                        try context.save()
                        alerta(mensagem: "Pauta atualizada com sucesso")
                    } catch {
                        alerta(mensagem: "Erro ao tentar atualizar pauta, tente novamente")
                    }
                }
            }
        }catch let erro as Error? {
            alerta(mensagem: "Erro ao recupertar pautas \(erro!.localizedDescription)")
        }
            
    }
    
    func recuperarPautasAberta() {
        self.pautasAbertas.removeAll()
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Pauta")
        let predicate = NSPredicate (format:"status = %@", "Aberto")
        requisicao.predicate = predicate
        do {
            let pautasRecuperadas = try context.fetch(requisicao)
            if pautasRecuperadas.count > 0 {
                self.pautasAbertas = pautasRecuperadas as! [NSManagedObject]
            }
        }catch let erro as Error? {
            alerta(mensagem: "Erro ao recupertar pautas \(erro!.localizedDescription)")
        }
        tableViewPauta.reloadData()
    }
    
    func recuperarPautasFechadas() {
        self.pautasFechadas.removeAll()
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Pauta")
        let predicate = NSPredicate (format:"status = %@", "Fechado")
        requisicao.predicate = predicate
        do {
            let pautasRecuperadas = try context.fetch(requisicao)
            if pautasRecuperadas.count > 0 {
                self.pautasFechadas = pautasRecuperadas as! [NSManagedObject]
            }
        }catch let erro as Error? {
            alerta(mensagem: "Erro ao recupertar pautas \(erro!.localizedDescription)")
        }
        tableViewPauta.reloadData()
    }
    
    func verificaSeUsuarioLogado() {
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuario")
        let predicate = NSPredicate (format:"login = %@", "S")
        requisicao.predicate = predicate
        do {
            let result = try context.fetch(requisicao)
            if result.count > 0 {
                for data in result as! [NSManagedObject] {
                    if data.value(forKey: "login") as! String == "S" {
                        nome = (data.value(forKey: "nome") as! String)
                        print("Usuario logado: ", data.value(forKey: "email") as! String)
                    }else {
                        voltarParaTelaLogin()
                        print("Nenhum usuario logado")
                    }
                }
            }else {
                voltarParaTelaLogin()
                print("Nenhum usuario logado")
            }
        } catch {
            print("Failed")
        }
    }
    
    func voltarParaTelaLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginPageID") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func alerta(mensagem: String) {
        let alert = UIAlertController(title: "Atenção", message: "\(mensagem)", preferredStyle: .alert)
        if mensagem == "Pauta atualizada com sucesso" {
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                self.recuperarPautasAberta()
                self.recuperarPautasFechadas()
            }))
        }else {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}
