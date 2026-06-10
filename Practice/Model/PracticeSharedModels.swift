//
//  PracticeSharedModels.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

// Combined Models for Practice
import Foundation
import simd
import SwiftUI
import ARKit
import SceneKit
import Foundation
import simd

// Represents a single atom in the molecule.
struct PracticeAtom: Identifiable, Equatable {
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


// --- PracticeBond ---
//
//  PracticeBond.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation

// Represents a bond between two atoms in the molecule.
struct PracticeBond: Identifiable, Equatable {
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
            case .single: return "Single PracticeBond"
            case .double: return "Double PracticeBond"
            case .triple: return "Triple PracticeBond"
            }
        }
    }
}


// --- PracticeMolecule ---
//
//  PracticeMolecule.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation

struct PracticeMolecule: Identifiable, Equatable {
    let id: UUID
    var atoms: [PracticeAtom]
    var bonds: [PracticeBond]
    var highlightedAtoms: Set<UUID> = []

    init(id: UUID = UUID(), atoms: [PracticeAtom] = [], bonds: [PracticeBond] = [], highlightedAtoms: Set<UUID> = []) {
        self.id = id
        self.atoms = atoms
        self.bonds = bonds
        self.highlightedAtoms = highlightedAtoms
    }

    // Returns the atom with the given id, or nil if not found.
    func atom(with id: UUID) -> PracticeAtom? {
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


// --- PracticeMolecule+Formula ---
//
//  PracticeMolecule+Formula.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation

extension PracticeMolecule {
    var chemicalFormula: String {
        let carbonCount   = atoms.filter { $0.element == .carbon }.count
        let hydrogenCount = atoms.filter { $0.element == .hydrogen }.count

        var formula = ""
        if carbonCount   > 0 { formula += "C" + (carbonCount   > 1 ? "\(carbonCount)"   : "") }
        if hydrogenCount > 0 { formula += "H" + (hydrogenCount > 1 ? "\(hydrogenCount)" : "") }
        return formula.isEmpty ? "-" : formula
    }
}


// --- PracticeMoleculeBuilder ---
//
//  PracticeMoleculeBuilder.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation
import simd
import Observation

// Used as the single source of truth by VisualizeViewModel.
@Observable
class PracticeMoleculeBuilder {
    var molecule: PracticeMolecule

    init(molecule: PracticeMolecule = PracticeMolecule()) {
        self.molecule = molecule
    }

    // PracticeAtom Operations

    @discardableResult
    func addAtom(element: PracticeAtom.Element, position: SIMD3<Float>) -> PracticeAtom {
        let atom = PracticeAtom(position: position, element: element)
        molecule.atoms.append(atom)
        return atom
    }

    func removeAtom(_ atom: PracticeAtom) {
        // Remove all bonds involving this atom before removing the atom itself.
        molecule.bonds.removeAll { $0.fromAtomId == atom.id || $0.toAtomId == atom.id }
        molecule.atoms.removeAll { $0.id == atom.id }
    }

    // PracticeBond Operations

    func bondExists(from: UUID, to: UUID) -> PracticeBond? {
        molecule.bonds.first {
            ($0.fromAtomId == from && $0.toAtomId == to) ||
            ($0.fromAtomId == to   && $0.toAtomId == from)
        }
    }

    // Adds a bond if one doesn't already exist and both atoms have enough valency.
    @discardableResult
    func addBond(from fromAtom: PracticeAtom, to toAtom: PracticeAtom, type: PracticeBond.BondType = .single) -> Bool {
        guard bondExists(from: fromAtom.id, to: toAtom.id) == nil else { return false }

        let fromValency = currentValency(for: fromAtom)
        let toValency   = currentValency(for: toAtom)

        guard fromValency + type.rawValue <= fromAtom.element.maxBonds,
              toValency   + type.rawValue <= toAtom.element.maxBonds else { return false }

        molecule.bonds.append(PracticeBond(from: fromAtom.id, to: toAtom.id, type: type))
        return true
    }

    func removeBond(_ bond: PracticeBond) {
        molecule.bonds.removeAll { $0.id == bond.id }
    }

    // PracticeMolecule-level Operations

    func clear() {
        molecule = PracticeMolecule()
    }

    func setMolecule(_ molecule: PracticeMolecule) {
        self.molecule = molecule
    }

    // Helpers

    private func currentValency(for atom: PracticeAtom) -> Int {
        molecule.bonds
            .filter { $0.fromAtomId == atom.id || $0.toAtomId == atom.id }
            .reduce(0) { $0 + $1.type.rawValue }
    }
    func fillHydrogens() {
        let heavyAtoms = molecule.atoms.filter { $0.element != .hydrogen }
        let bondLen: Float = 2.5

        // sp3 tetrahedral directions.
        let slots: [SIMD3<Float>] = [
            SIMD3<Float>( 0.577,  0.577,  0.577),
            SIMD3<Float>( 0.577, -0.577, -0.577),
            SIMD3<Float>(-0.577,  0.577, -0.577),
            SIMD3<Float>(-0.577, -0.577,  0.577)
        ]

        for atom in heavyAtoms {
            let needed = atom.element.maxBonds - currentValency(for: atom)
            guard needed > 0 else { continue }

            let connectedIds   = molecule.getConnections(for: atom.id)
            var occupiedSlots  = Set<Int>()

            for cid in connectedIds {
                guard let other = molecule.atom(with: cid) else { continue }
                let dir = other.position - atom.position
                let best = slots.enumerated().max { a, b in
                    (a.element.x*dir.x + a.element.y*dir.y + a.element.z*dir.z) <
                    (b.element.x*dir.x + b.element.y*dir.y + b.element.z*dir.z)
                }?.offset ?? 0
                occupiedSlots.insert(best)
            }

            var added = 0
            for (i, slot) in slots.enumerated() {
                guard added < needed, !occupiedSlots.contains(i) else { continue }
                let hAtom = addAtom(element: .hydrogen, position: atom.position + slot * bondLen)
                addBond(from: atom, to: hAtom, type: .single)
                added += 1
            }
        }
    }

    // Builds a straight-chain alkane with the given number of carbons and fills hydrogens.
    func buildAlkane(carbonCount: Int) {
        clear()
        guard carbonCount > 0 else { return }

        let bondLength:   Float = 3.0
        let zigZagOffset: Float = 1.2
        let startX = -Float(carbonCount - 1) * bondLength / 2.0

        var carbons: [PracticeAtom] = []
        for i in 0..<carbonCount {
            let x    = startX + Float(i) * bondLength
            let y    = (i % 2 == 0) ? Float(0) : zigZagOffset
            let atom = addAtom(element: .carbon, position: SIMD3<Float>(x, y, 0))
            carbons.append(atom)
            if i > 0 { addBond(from: carbons[i - 1], to: atom, type: .single) }
        }

        fillHydrogens()
    }
}


// --- PracticeIUPACNamingLogic ---
//
//  PracticeIUPACNamingLogic.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation

struct PracticeIUPACNamingLogic {

    static func generateName(for molecule: PracticeMolecule) -> String {
        guard !molecule.atoms.isEmpty else { return "Empty" }

        let carbons = molecule.atoms.filter { $0.element == .carbon }

        // Handle non-carbon molecules.
        if carbons.isEmpty {
            if molecule.atoms.contains(where: { $0.element == .hydrogen }) { return "Hydrogen Gas" }
            if molecule.atoms.contains(where: { $0.element == .oxygen })   { return "Oxygen Gas" }
            return "Unknown"
        }

        // Determine base suffix from the highest bond order in the main chain.
        let longestChain = findLongestCarbonChain(in: molecule)
        let chainLength  = longestChain.count

        var suffix    = "ane"
        var hasDouble = false
        var hasTriple = false

        for i in 0..<chainLength - 1 {
            let a1 = longestChain[i], a2 = longestChain[i + 1]
            if let bond = molecule.bonds.first(where: {
                ($0.fromAtomId == a1.id && $0.toAtomId == a2.id) ||
                ($0.fromAtomId == a2.id && $0.toAtomId == a1.id)
            }) {
                if bond.type == .double { hasDouble = true }
                if bond.type == .triple { hasTriple = true }
            }
        }

        if hasDouble && hasTriple {
            suffix = "enyne"
        } else if hasTriple {
            suffix = "yne"
        } else if hasDouble {
            suffix = "ene"
        }

        // Append -ol suffix for alcohols (oxygen present).
        if molecule.atoms.contains(where: { $0.element == .oxygen }) {
            switch suffix {
            case "ane":   suffix = "anol"
            case "ene":   suffix = "enol"
            case "yne":   suffix = "ynol"
            case "enyne": suffix = "en-1-ol"
            default:      suffix = suffix + "ol"
            }
        }

        let prefix    = getPrefix(for: chainLength)
        var basicName = prefix + suffix

        // Check for methyl branch substituents off the main chain.
        let chainIds       = Set(longestChain.map { $0.id })
        let branchedCarbons = carbons.filter { !chainIds.contains($0.id) }

        if branchedCarbons.count == 1 {
            let branchCarbon = branchedCarbons[0]
            let connections  = molecule.getConnections(for: branchCarbon.id)
            if let parentId = connections.first(where: { chainIds.contains($0) }),
               let index    = longestChain.firstIndex(where: { $0.id == parentId }) {
                basicName = "\(index + 1)-methyl" + basicName.lowercased()
            } else {
                basicName = "methyl" + basicName.lowercased()
            }
        }

        return basicName
    }

    // Returns the number of hydrogens needed to fully saturate the current molecule.
    static func calculateTheoreticalHydrogens(for molecule: PracticeMolecule) -> Int {
        let carbons = molecule.atoms.filter { $0.element == .carbon }
        return carbons.reduce(0) { total, carbon in
            var bondsToNonH = 0
            for bond in molecule.bonds {
                guard bond.fromAtomId == carbon.id || bond.toAtomId == carbon.id else { continue }
                let partnerId = (bond.fromAtomId == carbon.id) ? bond.toAtomId : bond.fromAtomId
                if let partner = molecule.atom(with: partnerId), partner.element != .hydrogen {
                    bondsToNonH += bond.type.rawValue
                }
            }
            return total + max(0, 4 - bondsToNonH)
        }
    }

    // Finds the longest continuous carbon chain using DFS from every carbon node.
    static func findLongestCarbonChain(in molecule: PracticeMolecule) -> [PracticeAtom] {
        let carbons = molecule.atoms.filter { $0.element == .carbon }
        guard !carbons.isEmpty else { return [] }
        return carbons.map { dfsLongestChain(current: $0, visited: [$0.id], molecule: molecule) }
                      .max { $0.count < $1.count } ?? []
    }

    private static func dfsLongestChain(current: PracticeAtom, visited: Set<UUID>, molecule: PracticeMolecule) -> [PracticeAtom] {
        let neighbors = molecule.getConnections(for: current.id)
            .compactMap { molecule.atom(with: $0) }
            .filter { $0.element == .carbon && !visited.contains($0.id) }

        guard !neighbors.isEmpty else { return [current] }

        let best = neighbors.map { neighbor -> [PracticeAtom] in
            var seen = visited
            seen.insert(neighbor.id)
            return dfsLongestChain(current: neighbor, visited: seen, molecule: molecule)
        }.max { $0.count < $1.count } ?? []

        return [current] + best
    }

    // Standard IUPAC prefixes for 1–10 carbon chains.
    static func getPrefix(for length: Int) -> String {
        switch length {
        case 1: return "Meth"
        case 2: return "Eth"
        case 3: return "Prop"
        case 4: return "But"
        case 5: return "Pent"
        case 6: return "Hex"
        case 7: return "Hept"
        case 8: return "Oct"
        case 9: return "Non"
        case 10: return "Dec"
        default: return "Poly"
        }
    }
}


// --- PracticeMolecule3DView ---
//
//  PracticeMolecule3DView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import SceneKit

struct PracticeMolecule3DView: UIViewRepresentable {
    @Binding var molecule: PracticeMolecule
    var cameraDistance: Float = 25
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = PracticeMoleculeScene(cameraDistance: cameraDistance)
        view.scene = scene
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let scene = uiView.scene as? PracticeMoleculeScene {
            scene.update(with: molecule)
        }
    }
}


// --- PracticeMoleculeScene ---
//
//  PracticeMoleculeScene.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SceneKit
import UIKit

class PracticeMoleculeScene: SCNScene {
    var molecule: PracticeMolecule?
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
    
    func update(with newMolecule: PracticeMolecule) {
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
    
    func createAtomNode(for atom: PracticeAtom, centerOffset: SIMD3<Float> = .zero) -> SCNNode {
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
    
    func createBondNode(from item1: PracticeAtom, to item2: PracticeAtom, type: PracticeBond.BondType, centerOffset: SIMD3<Float> = .zero) -> SCNNode {
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
    
    func setHighlight(_ highlighted: Bool, for node: SCNNode, element: PracticeAtom.Element) {
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


// --- PracticeARMoleculeView ---
//
//  PracticeARMoleculeView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import SceneKit
import ARKit

@Observable
class MoleculePracticeState {
    
    var isOffScreen: Bool = false
    var directionX: CGFloat = 0
    var directionY: CGFloat = 0
}

// PracticeARMoleculeView
struct PracticeARMoleculeView: UIViewRepresentable {
    @Binding var molecule: PracticeMolecule
    var finderState: MoleculePracticeState
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
        private let finderState: MoleculePracticeState

        init(finderState: MoleculePracticeState) {
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

        func rebuildMolecule(_ molecule: PracticeMolecule, in container: SCNNode) {
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
                    let cyl  = SCNCylinder(radius: 0.15, height: CGFloat(distance))
                    cyl.materials = [bondMat]
                    let n = SCNNode(geometry: cyl)
                    n.position = offset
                    return n
                }

                let bondContainer = SCNNode()
                bondContainer.position = midPoint
                bondContainer.look(at: p2, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 1, 0))

                let off: Float = 0.55
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

// PracticeGlassCircleButton
struct PracticeGlassCircleButton: View {
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

// PracticeGlassPill
struct PracticeGlassPill<Content: View>: View {
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

// PracticeMolecule Practice Overlay
struct MoleculePracticeOverlay: View {
    var state: MoleculePracticeState
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

struct PracticeARViewOnlySheet: View {
    @Binding var molecule: PracticeMolecule
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var finderState = MoleculePracticeState()
    @State private var triggerScreenshot = false

    var body: some View {
        NavigationStack {
            ZStack {
                PracticeARMoleculeView(molecule: $molecule, finderState: finderState, triggerScreenshot: $triggerScreenshot)
                    .edgesIgnoringSafeArea(.all)

                MoleculePracticeOverlay(state: finderState)

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
                        PracticeGlassPill {
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

