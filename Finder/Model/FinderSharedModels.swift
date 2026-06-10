//
//  FinderAtom.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

// Combined Models for Finder
import Foundation
import simd
import SwiftUI
import ARKit
import SceneKit
import Foundation
import simd

// Represents a single atom in the molecule.
struct FinderAtom: Identifiable, Equatable {
    let id: UUID
    var position: SIMD3<Float>
    let element: Element

    init(id: UUID = UUID(), position: SIMD3<Float> = .zero, element: Element) {
        self.id = id
        self.position = position
        self.element = element
    }

    enum Element: String, CaseIterable {
        case carbon   = "C"
        case hydrogen = "H"
        case oxygen   = "O"

        // CPK color as a hex string, used by the 3D renderers.
        var colorHex: String {
            switch self {
            case .carbon:   return "#333333"
            case .hydrogen: return "#FFFFFF"
            case .oxygen:   return "#FF3B30"
            }
        }

        var atomicMass: Float {
            switch self {
            case .carbon:   return 12.011
            case .hydrogen: return 1.008
            case .oxygen:   return 15.999
            }
        }

        // How many bonds this element can form at most.
        var maxBonds: Int {
            switch self {
            case .carbon:   return 4
            case .hydrogen: return 1
            case .oxygen:   return 2
            }
        }

        // Relative sphere radius used when rendering in SceneKit.
        var radius: Float {
            switch self {
            case .carbon:   return 0.7
            case .hydrogen: return 0.4
            case .oxygen:   return 0.6
            }
        }
    }
}


// --- FinderBond ---
//
//  FinderBond.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation

// Represents a bond between two atoms in the molecule.
struct FinderBond: Identifiable, Equatable {
    let id: UUID
    let fromAtomId: UUID
    let toAtomId: UUID
    var type: BondType

    init(id: UUID = UUID(), from fromAtomId: UUID, to toAtomId: UUID, type: BondType = .single) {
        self.id = id
        self.fromAtomId = fromAtomId
        self.toAtomId = toAtomId
        self.type = type
    }

    enum BondType: Int, CaseIterable {
        case single = 1
        case double = 2
        case triple = 3

        var description: String {
            switch self {
            case .single: return "Single FinderBond"
            case .double: return "Double FinderBond"
            case .triple: return "Triple FinderBond"
            }
        }
    }
}


// --- FinderMolecule ---
//
//  FinderMolecule.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation

struct FinderMolecule: Identifiable, Equatable {
    let id: UUID
    var atoms: [FinderAtom]
    var bonds: [FinderBond]
    var highlightedAtoms: Set<UUID> = []

    init(id: UUID = UUID(), atoms: [FinderAtom] = [], bonds: [FinderBond] = [], highlightedAtoms: Set<UUID> = []) {
        self.id = id
        self.atoms = atoms
        self.bonds = bonds
        self.highlightedAtoms = highlightedAtoms
    }

    // Returns the atom with the given id, or nil if not found.
    func atom(with id: UUID) -> FinderAtom? {
        atoms.first { $0.id == id }
    }

    // Returns the ids of all atoms directly bonded to the given atom.
    func getConnections(for atomId: UUID) -> [UUID] {
        bonds.flatMap { bond -> [UUID] in
            if bond.fromAtomId == atomId { return [bond.toAtomId] }
            if bond.toAtomId   == atomId { return [bond.fromAtomId] }
            return []
        }
    }
}


// --- FinderMolecule+Formula ---
//
//  FinderMolecule+Formula.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation

extension FinderMolecule {
    var chemicalFormula: String {
        let carbonCount   = atoms.filter { $0.element == .carbon }.count
        let hydrogenCount = atoms.filter { $0.element == .hydrogen }.count

        var formula = ""
        if carbonCount   > 0 { formula += "C" + (carbonCount   > 1 ? "\(carbonCount)"   : "") }
        if hydrogenCount > 0 { formula += "H" + (hydrogenCount > 1 ? "\(hydrogenCount)" : "") }
        return formula.isEmpty ? "-" : formula
    }
}


// --- FinderMoleculeFactory ---
//
//  FinderMoleculeFactory.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation
import simd

// Factory for building preset molecules (alkanes, alkenes, alkynes, cycloalkanes, benzene, radicals).
struct FinderMoleculeFactory {
    static func buildAlkane(_ n: Int) -> FinderMolecule {
        return buildChain(carbons: n, hydrogens: 2 * n + 2, bonds: .single)
    }
    
    static func buildAlkene(_ n: Int) -> FinderMolecule {
        return buildChain(carbons: n, hydrogens: 2 * n, bonds: .double)
    }
    
    static func buildAlkyne(_ n: Int) -> FinderMolecule {
        return buildChain(carbons: n, hydrogens: 2 * n - 2, bonds: .triple)
    }
    
    static func buildCycloAlkane(_ n: Int) -> FinderMolecule {
        var atoms: [FinderAtom] = []
        var bondList: [FinderBond] = []
        
        let radius: Float = Float(n) * 0.6
        for i in 0..<n {
            let angle = (Float(i) / Float(n)) * 2 * .pi
            let x = radius * cos(angle)
            let y = radius * sin(angle)
            let pos = SIMD3<Float>(x, y, 0)
            
            let atom = FinderAtom(position: pos, element: .carbon)
            atoms.append(atom)
            
            if i > 0 {
                bondList.append(FinderBond(from: atoms[i-1].id, to: atom.id, type: .single))
            }
        }
        if n > 2 {
            bondList.append(FinderBond(from: atoms[n-1].id, to: atoms[0].id, type: .single))
        }
        
        // Add Hydrogens using tetrahedral slots
        let hBondLen: Float = 2.5
        let tetraSlots: [SIMD3<Float>] = [
            SIMD3<Float>( 0.577,  0.577,  0.577),
            SIMD3<Float>( 0.577, -0.577, -0.577),
            SIMD3<Float>(-0.577,  0.577, -0.577),
            SIMD3<Float>(-0.577, -0.577,  0.577)
        ]

        for atom in atoms.filter({ $0.element == .carbon }) {
            let connectedBonds = bondList.filter { $0.fromAtomId == atom.id || $0.toAtomId == atom.id }
            let needed = 2 // Cycloalkanes have 2 H per carbon
            
            // Find occupied slots from C-C bonds
            var occupiedSlots: Set<Int> = []
            for bond in connectedBonds {
                let otherId = bond.fromAtomId == atom.id ? bond.toAtomId : bond.fromAtomId
                if let other = atoms.first(where: { $0.id == otherId }) {
                    let dir = other.position - atom.position
                    var bestSlot = 0
                    var bestDot: Float = -999
                    for (i, slot) in tetraSlots.enumerated() {
                        let d = dir.x*slot.x + dir.y*slot.y + dir.z*slot.z
                        if d > bestDot { bestDot = d; bestSlot = i }
                    }
                    occupiedSlots.insert(bestSlot)
                }
            }
            
            var added = 0
            for (i, slot) in tetraSlots.enumerated() {
                guard added < needed else { break }
                if !occupiedSlots.contains(i) {
                    let pos = atom.position + slot * hBondLen
                    let hAtom = FinderAtom(position: pos, element: .hydrogen)
                    atoms.append(hAtom)
                    bondList.append(FinderBond(from: atom.id, to: hAtom.id, type: .single))
                    added += 1
                }
            }
        }
        
        return FinderMolecule(atoms: atoms, bonds: bondList)
    }

    static func buildBenzene() -> FinderMolecule {
        var atoms: [FinderAtom] = []
        var bondList: [FinderBond] = []
        
        let radius: Float = 2.8
        for i in 0..<6 {
            let angle = (Float(i) / 6.0) * 2 * .pi
            let x = radius * cos(angle)
            let y = radius * sin(angle)
            let pos = SIMD3<Float>(x, y, 0)
            
            let atom = FinderAtom(position: pos, element: .carbon)
            atoms.append(atom)
            
            if i > 0 {
                let type: FinderBond.BondType = (i % 2 == 0) ? .single : .double
                bondList.append(FinderBond(from: atoms[i-1].id, to: atom.id, type: type))
            }
        }
        bondList.append(FinderBond(from: atoms[5].id, to: atoms[0].id, type: .double))
        
        // Add Hydrogens (1 per Carbon, pointing outward)
        let hBondLen: Float = 2.5
        for atom in atoms {
            let dir = normalize(atom.position)
            let pos = atom.position + dir * hBondLen
            
            let hAtom = FinderAtom(position: pos, element: .hydrogen)
            atoms.append(hAtom)
            bondList.append(FinderBond(from: atom.id, to: hAtom.id, type: .single))
        }
        
        return FinderMolecule(atoms: atoms, bonds: bondList)
    }

    static func buildRadical(_ n: Int) -> FinderMolecule {
        return buildChain(carbons: n, hydrogens: 2 * n + 1, bonds: .single)
    }

    static func buildAlcohol(_ n: Int) -> FinderMolecule {
        var mol = buildAlkane(n)
        let carbons = mol.atoms.filter { $0.element == .carbon }
        guard let terminalC = carbons.last else { return mol }
        
        let hBonds = mol.bonds.filter { $0.fromAtomId == terminalC.id || $0.toAtomId == terminalC.id }
        var targetH: FinderAtom?
        for b in hBonds {
            let otherId = (b.fromAtomId == terminalC.id) ? b.toAtomId : b.fromAtomId
            if let atom = mol.atoms.first(where: { $0.id == otherId && $0.element == .hydrogen }) {
                targetH = atom
                break
            }
        }
        guard let targetH = targetH else { return mol }
        
        if let idx = mol.atoms.firstIndex(where: { $0.id == targetH.id }) {
            mol.atoms[idx] = FinderAtom(id: targetH.id, position: targetH.position, element: .oxygen)
            let dir = normalize(targetH.position - terminalC.position)
            let newHPos = targetH.position + dir * 2.5
            let newH = FinderAtom(position: newHPos, element: .hydrogen)
            mol.atoms.append(newH)
            mol.bonds.append(FinderBond(from: targetH.id, to: newH.id, type: .single))
        }
        return mol
    }

    static func buildDiene(_ n: Int) -> FinderMolecule {
        return buildComplexChain(carbons: n, bondsPattern: [1: .double, n > 3 ? 3 : 2: .double])
    }

    static func buildEnyne(_ n: Int) -> FinderMolecule {
        return buildComplexChain(carbons: n, bondsPattern: [1: .double, n > 3 ? 3 : 2: .triple])
    }
    
    static func buildBranchedAlkane(_ n: Int) -> FinderMolecule {
        let mainChainLen = max(3, n - 1)
        var mol = buildAlkane(mainChainLen)
        
        let carbons = mol.atoms.filter { $0.element == .carbon }
        let attachC = carbons[1] // Attach to second carbon (e.g. isobutane)
        
        let hBonds = mol.bonds.filter { $0.fromAtomId == attachC.id || $0.toAtomId == attachC.id }
        var targetH: FinderAtom?
        var targetBondId: UUID?
        for b in hBonds {
            let otherId = (b.fromAtomId == attachC.id) ? b.toAtomId : b.fromAtomId
            if let atom = mol.atoms.first(where: { $0.id == otherId && $0.element == .hydrogen }) {
                targetH = atom
                targetBondId = b.id
                break
            }
        }
        
        guard let targetH = targetH, let bondId = targetBondId else { return mol }
        
        // Remove target H and its bond
        mol.atoms.removeAll(where: { $0.id == targetH.id })
        mol.bonds.removeAll(where: { $0.id == bondId })
        
        // Add new C branch
        let branchC = FinderAtom(position: targetH.position, element: .carbon)
        mol.atoms.append(branchC)
        mol.bonds.append(FinderBond(from: attachC.id, to: branchC.id, type: .single))
        
        // Fill H for branchC
        let hBondLen: Float = 2.5
        let tetraSlots: [SIMD3<Float>] = [
            SIMD3<Float>( 0.577,  0.577,  0.577),
            SIMD3<Float>( 0.577, -0.577, -0.577),
            SIMD3<Float>(-0.577,  0.577, -0.577),
            SIMD3<Float>(-0.577, -0.577,  0.577)
        ]
        
        let dir = normalize(attachC.position - branchC.position)
        var bestSlot = 0
        var bestDot: Float = -999
        for (i, slot) in tetraSlots.enumerated() {
            let d = dir.x*slot.x + dir.y*slot.y + dir.z*slot.z
            if d > bestDot { bestDot = d; bestSlot = i }
        }
        
        for (i, slot) in tetraSlots.enumerated() {
            if i != bestSlot {
                let pos = branchC.position + slot * hBondLen
                let hAtom = FinderAtom(position: pos, element: .hydrogen)
                mol.atoms.append(hAtom)
                mol.bonds.append(FinderBond(from: branchC.id, to: hAtom.id, type: .single))
            }
        }
        
        // Adjust formula by adding remaining carbons if n > mainChainLen + 1, but for basic branched we just do one branch.
        return mol
    }

    static func buildCycloAlkene(_ n: Int) -> FinderMolecule {
        var mol = buildCycloAlkane(n)
        let carbons = mol.atoms.filter { $0.element == .carbon }
        guard carbons.count >= 2 else { return mol }
        
        // Make the bond between C0 and C1 double
        if let idx = mol.bonds.firstIndex(where: { 
            ($0.fromAtomId == carbons[0].id && $0.toAtomId == carbons[1].id) ||
            ($0.fromAtomId == carbons[1].id && $0.toAtomId == carbons[0].id)
        }) {
            mol.bonds[idx].type = .double
        }
        
        // Remove 1 H from C0 and 1 H from C1
        for c in [carbons[0], carbons[1]] {
            let hBonds = mol.bonds.filter { $0.fromAtomId == c.id || $0.toAtomId == c.id }
            for b in hBonds {
                let otherId = (b.fromAtomId == c.id) ? b.toAtomId : b.fromAtomId
                if let atom = mol.atoms.first(where: { $0.id == otherId && $0.element == .hydrogen }) {
                    mol.atoms.removeAll(where: { $0.id == atom.id })
                    mol.bonds.removeAll(where: { $0.id == b.id })
                    break
                }
            }
        }
        return mol
    }
    
    private static func buildComplexChain(carbons: Int, bondsPattern: [Int: FinderBond.BondType]) -> FinderMolecule {
        var atoms: [FinderAtom] = []
        var bondList: [FinderBond] = []
        
        let spacing: Float = 3.0
        let zigzag: Float = 1.2
        var carbonAtoms: [FinderAtom] = []
        let startX = -Float(carbons - 1) * spacing / 2.0
        
        for i in 0..<carbons {
            let x = startX + Float(i) * spacing
            let y = (i % 2 == 0) ? 0.0 : zigzag
            let pos = SIMD3<Float>(x, Float(y), 0)
            let atom = FinderAtom(position: pos, element: .carbon)
            atoms.append(atom)
            carbonAtoms.append(atom)
            
            if i > 0 {
                let prev = carbonAtoms[i-1]
                let type: FinderBond.BondType = bondsPattern[i] ?? .single
                bondList.append(FinderBond(from: prev.id, to: atom.id, type: type))
            }
        }
        
        // Add Hydrogens using tetrahedral slots
        let hBondLen: Float = 2.5
        let tetraSlots: [SIMD3<Float>] = [
            SIMD3<Float>( 0.577,  0.577,  0.577),
            SIMD3<Float>( 0.577, -0.577, -0.577),
            SIMD3<Float>(-0.577,  0.577, -0.577),
            SIMD3<Float>(-0.577, -0.577,  0.577)
        ]
        
        for atom in carbonAtoms {
            let connections = bondList.filter { $0.fromAtomId == atom.id || $0.toAtomId == atom.id }
            var currentValency = 0
            for b in connections { currentValency += b.type.rawValue }
            let needed = 4 - currentValency
            
            guard needed > 0 else { continue }
            
            var occupiedSlots: Set<Int> = []
            for bond in connections {
                let otherId = bond.fromAtomId == atom.id ? bond.toAtomId : bond.fromAtomId
                if let other = atoms.first(where: { $0.id == otherId }) {
                    let dir = other.position - atom.position
                    var bestSlot = 0
                    var bestDot: Float = -999
                    for (i, slot) in tetraSlots.enumerated() {
                        let d = dir.x*slot.x + dir.y*slot.y + dir.z*slot.z
                        if d > bestDot { bestDot = d; bestSlot = i }
                    }
                    occupiedSlots.insert(bestSlot)
                }
            }
            
            var added = 0
            for (i, slot) in tetraSlots.enumerated() {
                guard added < needed else { break }
                if !occupiedSlots.contains(i) {
                    let pos = atom.position + slot * hBondLen
                    let hAtom = FinderAtom(position: pos, element: .hydrogen)
                    atoms.append(hAtom)
                    bondList.append(FinderBond(from: atom.id, to: hAtom.id, type: .single))
                    added += 1
                }
            }
        }
        return FinderMolecule(atoms: atoms, bonds: bondList)
    }

    private static func buildChain(carbons: Int, hydrogens: Int, bonds: FinderBond.BondType) -> FinderMolecule {
        var atoms: [FinderAtom] = []
        var bondList: [FinderBond] = []
        
        // 1. Place Carbons (ZigZag) — 3.0 spacing, 1.2 zigzag
        let spacing: Float = 3.0
        let zigzag: Float = 1.2
        var carbonAtoms: [FinderAtom] = []
        let startX = -Float(carbons - 1) * spacing / 2.0
        
        for i in 0..<carbons {
            let x = startX + Float(i) * spacing
            let y = (i % 2 == 0) ? 0.0 : zigzag
            let pos = SIMD3<Float>(x, Float(y), 0)
            let atom = FinderAtom(position: pos, element: .carbon)
            atoms.append(atom)
            carbonAtoms.append(atom)
            
            if i > 0 {
                let prev = carbonAtoms[i-1]
                var type: FinderBond.BondType = .single
                if i == 1 {
                    if bonds == .double { type = .double }
                    if bonds == .triple { type = .triple }
                }
                bondList.append(FinderBond(from: prev.id, to: atom.id, type: type))
            }
        }
        
        // 2. Add Hydrogens using tetrahedral slots
        let hBondLen: Float = 2.5
        let tetraSlots: [SIMD3<Float>] = [
            SIMD3<Float>( 0.577,  0.577,  0.577),
            SIMD3<Float>( 0.577, -0.577, -0.577),
            SIMD3<Float>(-0.577,  0.577, -0.577),
            SIMD3<Float>(-0.577, -0.577,  0.577)
        ]
        
        var hydrogensAdded = 0
        
        for atom in carbonAtoms {
            let connections = bondList.filter { $0.fromAtomId == atom.id || $0.toAtomId == atom.id }
            var currentValency = 0
            for b in connections { currentValency += b.type.rawValue }
            let needed = 4 - currentValency
            
            guard needed > 0 else { continue }
            
            // Find occupied slots from existing bonds
            var occupiedSlots: Set<Int> = []
            for bond in connections {
                let otherId = bond.fromAtomId == atom.id ? bond.toAtomId : bond.fromAtomId
                if let other = atoms.first(where: { $0.id == otherId }) {
                    let dir = other.position - atom.position
                    var bestSlot = 0
                    var bestDot: Float = -999
                    for (i, slot) in tetraSlots.enumerated() {
                        let d = dir.x*slot.x + dir.y*slot.y + dir.z*slot.z
                        if d > bestDot { bestDot = d; bestSlot = i }
                    }
                    occupiedSlots.insert(bestSlot)
                }
            }
            
            var added = 0
            for (i, slot) in tetraSlots.enumerated() {
                guard added < needed else { break }
                guard hydrogensAdded < hydrogens else { break }
                if !occupiedSlots.contains(i) {
                    let pos = atom.position + slot * hBondLen
                    let hAtom = FinderAtom(position: pos, element: .hydrogen)
                    atoms.append(hAtom)
                    bondList.append(FinderBond(from: atom.id, to: hAtom.id, type: .single))
                    hydrogensAdded += 1
                    added += 1
                }
            }
        }
        return FinderMolecule(atoms: atoms, bonds: bondList)
    }
    
    private static func normalize(_ v: SIMD3<Float>) -> SIMD3<Float> {
        let length = sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
        return length == 0 ? .zero : v / length
    }
}


// --- FinderMolecule3DView ---
//
//  FinderMolecule3DView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import SceneKit

struct FinderMolecule3DView: UIViewRepresentable {
    @Binding var molecule: FinderMolecule
    var cameraDistance: Float = 25
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = FinderMoleculeScene(cameraDistance: cameraDistance)
        view.scene = scene
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let scene = uiView.scene as? FinderMoleculeScene {
            scene.update(with: molecule)
        }
    }
}


// --- FinderMoleculeScene ---
//
//  FinderMoleculeScene.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SceneKit
import UIKit

class FinderMoleculeScene: SCNScene {
    var molecule: FinderMolecule?
    var atomNodes: [UUID: SCNNode] = [:]
    var bondNodes: [UUID: SCNNode] = [:]
    
    init(cameraDistance: Float = 25) {
        super.init()
        setupLighting(distance: cameraDistance)
        setupCamera(distance: cameraDistance)
    }
    
    override init() {
        super.init()
        setupLighting(distance: 25)
        setupCamera(distance: 25)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLighting(distance: Float) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.intensity = 1200
        lightNode.light?.color = UIColor.white
        lightNode.position = SCNVector3(x: 0, y: distance * 0.65, z: distance * 0.65)
        rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.intensity = 800
        ambientLightNode.light?.color = UIColor(white: 0.5, alpha: 1.0)
        rootNode.addChildNode(ambientLightNode)
        
        let fillLightNode = SCNNode()
        fillLightNode.light = SCNLight()
        fillLightNode.light?.type = .omni
        fillLightNode.light?.intensity = 600
        fillLightNode.light?.color = UIColor.white
        fillLightNode.position = SCNVector3(x: 0, y: -distance * 0.35, z: distance * 0.5)
        rootNode.addChildNode(fillLightNode)
    }
    
    func setupCamera(distance: Float) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 60
        cameraNode.position = SCNVector3(x: 0, y: 0, z: distance)
        rootNode.addChildNode(cameraNode)
    }
    
    func update(with newMolecule: FinderMolecule) {
        self.molecule = newMolecule
        
        // We find the geometric center to keep the molecule from "drifting" when rotating.
        let center: SIMD3<Float> = {
            guard !newMolecule.atoms.isEmpty else { return .zero }
            let positions = newMolecule.atoms.map { $0.position }
            let sum = positions.reduce(SIMD3<Float>.zero, +)
            return sum / Float(positions.count)
        }()
        
        let removedAtomIds = atomNodes.keys.filter { newMolecule.atom(with: $0) == nil }
        for id in removedAtomIds {
            atomNodes[id]?.removeFromParentNode()
            atomNodes.removeValue(forKey: id)
        }
        
        let removedBondIds = bondNodes.keys.filter { id in
            !newMolecule.bonds.contains(where: { $0.id == id })
        }
        for id in removedBondIds {
            bondNodes[id]?.removeFromParentNode()
            bondNodes.removeValue(forKey: id)
        }
        
        for atom in newMolecule.atoms {
            let isHighlighted = newMolecule.highlightedAtoms.contains(atom.id)
            let centeredPos = atom.position - center
            
            if let existingNode = atomNodes[atom.id] {
                let action = SCNAction.move(to: SCNVector3(centeredPos), duration: 0.3)
                existingNode.runAction(action)
                setHighlight(isHighlighted, for: existingNode, element: atom.element)
            } else {
                let node = createAtomNode(for: atom, centerOffset: center)
                rootNode.addChildNode(node)
                atomNodes[atom.id] = node
                setHighlight(isHighlighted, for: node, element: atom.element)
                node.scale = SCNVector3(0, 0, 0)
                node.runAction(SCNAction.scale(to: 1, duration: 0.5))
            }
        }
        
        for bond in newMolecule.bonds {
            if bondNodes[bond.id] == nil {
                if let fromAtom = newMolecule.atom(with: bond.fromAtomId),
                   let toAtom = newMolecule.atom(with: bond.toAtomId) {
                    let node = createBondNode(from: fromAtom, to: toAtom, type: bond.type, centerOffset: center)
                    node.opacity = 0
                    rootNode.addChildNode(node)
                    bondNodes[bond.id] = node
                    let fadeIn = SCNAction.sequence([SCNAction.wait(duration: 0.3), SCNAction.fadeIn(duration: 0.4)])
                    node.runAction(fadeIn)
                }
            } else {
                let bondNode = bondNodes[bond.id]!
                bondNode.removeFromParentNode()
                if let fromAtom = newMolecule.atom(with: bond.fromAtomId),
                   let toAtom = newMolecule.atom(with: bond.toAtomId) {
                    let newNode = createBondNode(from: fromAtom, to: toAtom, type: bond.type, centerOffset: center)
                    rootNode.addChildNode(newNode)
                    bondNodes[bond.id] = newNode
                }
            }
        }
    }
    
    func createAtomNode(for atom: FinderAtom, centerOffset: SIMD3<Float> = .zero) -> SCNNode {
        let radius = CGFloat(atom.element.radius)
        let geometry = SCNSphere(radius: radius)
        let material = SCNMaterial()
        material.lightingModel = .phong
        
        if atom.element == .carbon {
            material.diffuse.contents = UIColor(red: 0.0, green: 0.8, blue: 0.85, alpha: 1.0)
            material.specular.contents = UIColor.white
            material.shininess = 60
        } else {
            material.diffuse.contents = UIColor(white: 0.92, alpha: 1.0)
            material.specular.contents = UIColor(white: 0.6, alpha: 1.0)
            material.shininess = 60
        }
        
        geometry.materials = [material]
        let centeredPos = atom.position - centerOffset
        let atomNode = SCNNode(geometry: geometry)
        atomNode.position = SCNVector3(centeredPos)
        
        let textGeometry = SCNText(string: atom.element.rawValue, extrusionDepth: 0.05)
        textGeometry.font = UIFont.systemFont(ofSize: 1, weight: .heavy)
        textGeometry.flatness = 0.005
        
        let textNode = SCNNode(geometry: textGeometry)
        let fontSize: Float = 0.7
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        let (min, max) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2, (max.y - min.y) / 2, 0)
        
        let textMaterial = SCNMaterial()
        textMaterial.lightingModel = .constant
        textMaterial.diffuse.contents = UIColor.white
        
        textGeometry.materials = [textMaterial]
        textNode.position = SCNVector3(0, -0.25, Float(radius) + 0.01)
        atomNode.addChildNode(textNode)
        
        let billboard = SCNBillboardConstraint()
        billboard.freeAxes = .all
        textNode.constraints = [billboard]
        
        return atomNode
    }
    
    func createBondNode(from item1: FinderAtom, to item2: FinderAtom, type: FinderBond.BondType, centerOffset: SIMD3<Float> = .zero) -> SCNNode {
        let p1 = SCNVector3(item1.position - centerOffset)
        let p2 = SCNVector3(item2.position - centerOffset)
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let dz = p2.z - p1.z
        let distance = sqrt(dx * dx + dy * dy + dz * dz)
        let midPoint = SCNVector3((p1.x + p2.x) / 2, (p1.y + p2.y) / 2, (p1.z + p2.z) / 2)
        
        let containerNode = SCNNode()
        containerNode.position = midPoint
        containerNode.look(at: p2, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 1, 0))
        
        let bondMaterial = SCNMaterial()
        bondMaterial.lightingModel = .constant
        bondMaterial.diffuse.contents = UIColor.white
        bondMaterial.emission.contents = UIColor(white: 0.95, alpha: 1.0)
        
        let bondRadius: CGFloat = 0.15
        let bondHeight = CGFloat(distance)
        
        func makeCylinder(offset: SCNVector3) -> SCNNode {
            let cylinder = SCNCylinder(radius: bondRadius, height: bondHeight)
            cylinder.materials = [bondMaterial]
            let node = SCNNode(geometry: cylinder)
            node.position = offset
            return node
        }
        
        let offsetDistance: Float = 0.55
        
        switch type {
        case .single:
            containerNode.addChildNode(makeCylinder(offset: .init(0, 0, 0)))
        case .double:
            containerNode.addChildNode(makeCylinder(offset: .init(offsetDistance / 2, 0, 0)))
            containerNode.addChildNode(makeCylinder(offset: .init(-offsetDistance / 2, 0, 0)))
        case .triple:
            containerNode.addChildNode(makeCylinder(offset: .init(0, 0, 0)))
            containerNode.addChildNode(makeCylinder(offset: .init(offsetDistance, 0, 0)))
            containerNode.addChildNode(makeCylinder(offset: .init(-offsetDistance, 0, 0)))
        }
        
        return containerNode
    }
    
    func setHighlight(_ highlighted: Bool, for node: SCNNode, element: FinderAtom.Element) {
        guard let material = node.geometry?.firstMaterial else { return }
        
        if highlighted {
            material.emission.contents = UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
            if node.action(forKey: "pulse") == nil {
                let scaleUp = SCNAction.scale(to: 1.2, duration: 0.5)
                let scaleDown = SCNAction.scale(to: 1.0, duration: 0.5)
                let repeatAction = SCNAction.repeatForever(SCNAction.sequence([scaleUp, scaleDown]))
                node.runAction(repeatAction, forKey: "pulse")
            }
        } else {
            material.emission.contents = UIColor.black
            node.removeAction(forKey: "pulse")
            node.scale = SCNVector3(1, 1, 1)
        }
    }
}


// --- FinderARMoleculeView ---
//
//  FinderARMoleculeView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import SceneKit
import ARKit

@Observable
class FinderMoleculeFinderState {
    
    var isOffScreen: Bool = false
    var directionX: CGFloat = 0
    var directionY: CGFloat = 0
}

struct FinderARMoleculeView: UIViewRepresentable {
    @Binding var molecule: FinderMolecule
    var finderState: FinderMoleculeFinderState
    @Binding var triggerScreenshot: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(finderState: finderState)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator

        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.intensity = 1500
        lightNode.light?.color = UIColor.white
        lightNode.position = SCNVector3(0, 1, 1)
        arView.scene.rootNode.addChildNode(lightNode)

        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 800
        ambientLight.light?.color = UIColor.white
        arView.scene.rootNode.addChildNode(ambientLight)

        let anchorNode = SCNNode()
        anchorNode.name = "moleculeAnchor"
        arView.scene.rootNode.addChildNode(anchorNode)

        context.coordinator.anchorNode = anchorNode
        context.coordinator.arView = arView

        let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        arView.addGestureRecognizer(pinch)

        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        arView.addGestureRecognizer(pan)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        arView.session.run(configuration)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.placeMolecule(in: arView, coordinator: context.coordinator)
        }

        // Seed the cached bounds now; will be refreshed in updateUIView.
        context.coordinator.cachedViewBounds = arView.bounds
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.cachedViewBounds = uiView.bounds

        if triggerScreenshot {
            DispatchQueue.main.async {
                let image = uiView.snapshot()
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                self.triggerScreenshot = false
            }
        }

        guard let anchorNode = context.coordinator.anchorNode else { return }

        let newHash = molecule.atoms.map {
            Int($0.position.x * 100) + Int($0.position.y * 100) + Int($0.position.z * 100)
        }.reduce(0, +) + molecule.bonds.count * 1000

        if newHash != context.coordinator.lastHash {
            context.coordinator.rebuildMolecule(molecule, in: anchorNode)
        }
    }

    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        uiView.session.pause()
    }

    private func placeMolecule(in arView: ARSCNView, coordinator: Coordinator) {
        guard let anchorNode = coordinator.anchorNode else { return }

        if let frame = arView.session.currentFrame {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5
            anchorNode.simdTransform = frame.camera.transform * translation
        } else {
            anchorNode.position = SCNVector3(0, 0, -0.5)
        }

        anchorNode.scale = SCNVector3(0.02, 0.02, 0.02)
        coordinator.rebuildMolecule(molecule, in: anchorNode)
    }

    // Coordinator
    class Coordinator: NSObject, ARSCNViewDelegate {
        var anchorNode: SCNNode?
        var arView: ARSCNView?
        var lastHash: Int = -1
        var cachedViewBounds: CGRect = .zero

        private var initialScale: SCNVector3 = SCNVector3(1, 1, 1)
        private var lastPanPoint: CGPoint = .zero
        private let finderState: FinderMoleculeFinderState

        init(finderState: FinderMoleculeFinderState) {
            self.finderState = finderState
        }

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let arView = arView, let anchor = anchorNode else { return }

            let worldPos = anchor.worldPosition
            let projected = arView.projectPoint(worldPos)
            let bounds = cachedViewBounds
            let marginX = bounds.width  * 0.15
            let marginY = bounds.height * 0.15
            let innerBounds = bounds.insetBy(dx: marginX, dy: marginY)

            let isOnScreen = innerBounds.contains(CGPoint(x: CGFloat(projected.x), y: CGFloat(projected.y)))
                          && projected.z < 1.0
            let rawDX = CGFloat(projected.x) / bounds.width  - 0.5
            let rawDY = CGFloat(projected.y) / bounds.height - 0.5

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.finderState.isOffScreen = !isOnScreen
                self.finderState.directionX  = rawDX
                self.finderState.directionY  = rawDY
            }
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let node = anchorNode else { return }
            switch gesture.state {
            case .began:
                initialScale = node.scale
            case .changed:
                let s = Float(gesture.scale)
                let clamped = max(0.005, min(0.1, Float(initialScale.x) * s))
                node.scale = SCNVector3(clamped, clamped, clamped)
            default:
                break
            }
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let node = anchorNode, let arView = arView else { return }
            let location = gesture.location(in: arView)
            switch gesture.state {
            case .began:
                lastPanPoint = location
            case .changed:
                let dx = Float(location.x - lastPanPoint.x)
                let dy = Float(location.y - lastPanPoint.y)
                lastPanPoint = location
                let sensitivity: Float = 0.01
                let rotateX = SCNMatrix4MakeRotation(-dy * sensitivity, 1, 0, 0)
                let rotateY = SCNMatrix4MakeRotation(-dx * sensitivity, 0, 1, 0)
                node.transform = SCNMatrix4Mult(SCNMatrix4Mult(rotateX, rotateY), node.transform)
            default:
                break
            }
        }

        func rebuildMolecule(_ molecule: FinderMolecule, in container: SCNNode) {
            container.childNodes.forEach { $0.removeFromParentNode() }
            lastHash = molecule.atoms.map {
                Int($0.position.x * 100) + Int($0.position.y * 100) + Int($0.position.z * 100)
            }.reduce(0, +) + molecule.bonds.count * 1000

            guard !molecule.atoms.isEmpty else { return }

            let positions = molecule.atoms.map { $0.position }
            let center = positions.reduce(SIMD3<Float>.zero, +) / Float(positions.count)

            for atom in molecule.atoms {
                let centeredPos = atom.position - center
                let sphere = SCNSphere(radius: CGFloat(atom.element.radius))
                sphere.segmentCount = 24

                let material = SCNMaterial()
                material.lightingModel = .constant
                if atom.element == .carbon {
                    material.diffuse.contents  = UIColor(red: 0.0, green: 0.8, blue: 0.85, alpha: 1.0)
                    material.emission.contents = UIColor(red: 0.0, green: 0.4, blue: 0.45, alpha: 1.0)
                } else {
                    material.diffuse.contents  = UIColor(white: 0.92, alpha: 1.0)
                    material.emission.contents = UIColor(white: 0.5,  alpha: 1.0)
                }
                sphere.materials = [material]

                let atomNode = SCNNode(geometry: sphere)
                atomNode.position = SCNVector3(centeredPos)

                let textGeom = SCNText(string: atom.element.rawValue, extrusionDepth: 0.05)
                textGeom.font = UIFont.systemFont(ofSize: 1, weight: .heavy)
                textGeom.flatness = 0.005

                let textNode = SCNNode(geometry: textGeom)
                textNode.scale = SCNVector3(0.7, 0.7, 0.7)

                let (minB, maxB) = textNode.boundingBox
                textNode.pivot = SCNMatrix4MakeTranslation((maxB.x - minB.x) / 2, (maxB.y - minB.y) / 2, 0)

                let textMat = SCNMaterial()
                textMat.lightingModel = .constant
                textMat.diffuse.contents = UIColor.black
                textGeom.materials = [textMat]
                textNode.position = SCNVector3(0, -0.25, Float(atom.element.radius) + 0.01)
                textNode.constraints = [SCNBillboardConstraint()]
                atomNode.addChildNode(textNode)

                container.addChildNode(atomNode)
            }

            for bond in molecule.bonds {
                guard let fromAtom = molecule.atom(with: bond.fromAtomId),
                      let toAtom  = molecule.atom(with: bond.toAtomId) else { continue }

                let p1 = SCNVector3(fromAtom.position - center)
                let p2 = SCNVector3(toAtom.position  - center)
                let dx = p2.x - p1.x, dy = p2.y - p1.y, dz = p2.z - p1.z
                let distance = sqrt(dx*dx + dy*dy + dz*dz)
                let midPoint = SCNVector3((p1.x+p2.x)/2, (p1.y+p2.y)/2, (p1.z+p2.z)/2)

                let bondMat = SCNMaterial()
                bondMat.lightingModel = .constant
                bondMat.diffuse.contents  = UIColor.white
                bondMat.emission.contents = UIColor(white: 0.95, alpha: 1.0)

                func makeCylinder(offset: SCNVector3) -> SCNNode {
                    let cyl  = SCNCylinder(radius: 0.25, height: CGFloat(distance))
                    cyl.materials = [bondMat]
                    let n = SCNNode(geometry: cyl)
                    n.position = offset
                    return n
                }

                let bondContainer = SCNNode()
                bondContainer.position = midPoint
                bondContainer.look(at: p2, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 1, 0))

                let off: Float = 0.28
                switch bond.type {
                case .single: bondContainer.addChildNode(makeCylinder(offset: .init(0, 0, 0)))
                case .double:
                    bondContainer.addChildNode(makeCylinder(offset: .init( off/2, 0, 0)))
                    bondContainer.addChildNode(makeCylinder(offset: .init(-off/2, 0, 0)))
                case .triple:
                    bondContainer.addChildNode(makeCylinder(offset: .init(  0, 0, 0)))
                    bondContainer.addChildNode(makeCylinder(offset: .init( off, 0, 0)))
                    bondContainer.addChildNode(makeCylinder(offset: .init(-off, 0, 0)))
                }

                container.addChildNode(bondContainer)
            }
        }
    }
}

// FinderGlassCircleButton
struct FinderGlassCircleButton: View {
    let systemImage: String
    let tintColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(Circle().fill(tintColor.opacity(0.25)))
                    .overlay(
                        Circle().stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.1), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.75
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(GlassButtonStyle())
    }
}

// FinderGlassPill
struct FinderGlassPill<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(Capsule().fill(Color.white.opacity(0.06)))
                    .overlay(
                        Capsule().stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.45), .white.opacity(0.08), .white.opacity(0.03)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// FinderMolecule Finder Overlay
struct FinderMoleculeFinderOverlay: View {
    var state: FinderMoleculeFinderState
    @State private var pulse = false

    var body: some View {
        Group {
            if state.isOffScreen {
                ZStack {
                    if state.directionY < -0.25 {
                        DirectionalChevron(rotationDegrees: 90, pulse: pulse, axis: .vertical)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .padding(.top, 60)
                    }
                    // Bottom
                    if state.directionY > 0.25 {
                        DirectionalChevron(rotationDegrees: -90, pulse: pulse, axis: .vertical)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom, 160)
                    }
                    // Left
                    if state.directionX < -0.25 {
                        DirectionalChevron(rotationDegrees: 0, pulse: pulse, axis: .horizontal)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .padding(.leading, 36)
                    }
                    // Right
                    if state.directionX > 0.25 {
                        DirectionalChevron(rotationDegrees: 180, pulse: pulse, axis: .horizontal)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                            .padding(.trailing, 36)
                    }
                }
                .accessibilityHidden(true) // decorative directional cues — VoiceOver navigates spatially
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.65).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: state.isOffScreen)
    }
}

private struct DirectionalChevron: View {
    let rotationDegrees: Double
    let pulse: Bool

    enum Axis { case horizontal, vertical }
    let axis: Axis

    private var slideX: CGFloat {
        guard axis == .horizontal else { return 0 }
        return rotationDegrees == 0 ? (pulse ? -14 : 0) : (pulse ? 14 : 0)
    }
    private var slideY: CGFloat {
        guard axis == .vertical else { return 0 }
        return rotationDegrees == 90 ? (pulse ? -14 : 0) : (pulse ? 14 : 0)
    }

    private func trailOffsetX(for layer: Int) -> CGFloat {
        guard axis == .horizontal else { return 0 }
        let step: CGFloat = 14
        return rotationDegrees == 0 ? CGFloat(layer) * step : -CGFloat(layer) * step
    }
    private func trailOffsetY(for layer: Int) -> CGFloat {
        guard axis == .vertical else { return 0 }
        let step: CGFloat = 14
        return rotationDegrees == 90 ? CGFloat(layer) * step : -CGFloat(layer) * step
    }

    private func opacity(for layer: Int) -> Double {
        switch layer {
        case 0: return pulse ? 1.0  : 0.55
        case 1: return pulse ? 0.45 : 0.20
        default: return pulse ? 0.18 : 0.06
        }
    }

    var body: some View {
        ZStack {
            ForEach([2, 1, 0], id: \.self) { layer in
                Image(systemName: "chevron.backward.2")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(.white.opacity(opacity(for: layer)))
                    .rotationEffect(.degrees(rotationDegrees))
                    .offset(x: trailOffsetX(for: layer), y: trailOffsetY(for: layer))
            }
        }
        .offset(x: slideX, y: slideY)
        .shadow(color: .white.opacity(pulse ? 0.5 : 0.1), radius: pulse ? 12 : 4)
    }
}

struct FinderARViewOnlySheet: View {
    @Binding var molecule: FinderMolecule
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var finderState = FinderMoleculeFinderState()
    @State private var triggerScreenshot = false

    var body: some View {
        NavigationStack {
            ZStack {
                FinderARMoleculeView(molecule: $molecule, finderState: finderState, triggerScreenshot: $triggerScreenshot)
                    .edgesIgnoringSafeArea(.all)

                FinderMoleculeFinderOverlay(state: finderState)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        // Capture/Shutter Button
                        Button {
                            triggerScreenshot = true
                        } label: {
                            ZStack {
                                Circle()
                                    .stroke(.white, lineWidth: 3)
                                    .frame(width: 72, height: 72)
                                Circle()
                                    .fill(.white)
                                    .frame(width: 60, height: 60)
                            }
                        }
                        .accessibilityLabel("Take Screenshot")
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        
                        Spacer()
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(ToolbarIconStyle())
                    .accessibilityLabel("Close AR view")
                }
                ToolbarItem(placement: .principal) {
                    if !title.isEmpty {
                        FinderGlassPill {
                            Text(title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .accessibilityLabel(title)
                        .accessibilityAddTraits(.isStaticText)
                    }
                }
            }
        }
        .statusBarHidden()
    }
}

