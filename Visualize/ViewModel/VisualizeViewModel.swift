//
//  VisualizeViewModel.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import Observation
import simd

// to the view, along with derived display values like moleculeName and chemicalFormula.
@Observable
class VisualizeViewModel {
    var molecule: VisualizeMolecule = VisualizeMolecule()
    var moleculeName: String = ""
    var chemicalFormula: String = "-"
    var missingHydrogensText: String? = nil
    var selectedBondType: VisualizeBond.BondType = .single

    private let builder = VisualizeMoleculeBuilder()
    private var history: [VisualizeMolecule] = []

    init() {
        updateMetadata()
    }

    // VisualizeAtom Actions
    func addCarbon() {
        saveState()

        // Snapshot the current molecule and mutate the copy directly,
        // Set the entire molecule at once.
        var mol = builder.molecule

        let carbons  = mol.atoms.filter { $0.element == .carbon }
        let targetId = carbons.last?.id

        // Remove all hydrogens from the target carbon to free max valency.
        if let tId = targetId {
            let hIds = mol.getConnections(for: tId)
                .filter { mol.atom(with: $0)?.element == .hydrogen }
            for hId in hIds {
                mol.bonds.removeAll { $0.fromAtomId == hId || $0.toAtomId == hId }
                mol.atoms.removeAll { $0.id == hId }
            }
        }

        // Position the new carbon in a zigzag pattern.
        let position: SIMD3<Float>
        if let tId = targetId, let target = mol.atom(with: tId) {
            let yOffset: Float = (carbons.count % 2 == 0) ? -1.2 : 1.2
            position = target.position + SIMD3<Float>(3.0, yOffset, 0)
        } else {
            position = .zero
        }

        let newCarbon = VisualizeAtom(position: position, element: .carbon)
        mol.atoms.append(newCarbon)

        // Determine the best bond type that fits.
        if let tId = targetId {
            let targetValency = mol.valency(for: tId)
            let freeSlots = VisualizeAtom.Element.carbon.maxBonds - targetValency

            let bondType: VisualizeBond.BondType
            if selectedBondType.rawValue <= freeSlots {
                bondType = selectedBondType
            } else if freeSlots >= 3 {
                bondType = .triple
            } else if freeSlots >= 2 {
                bondType = .double
            } else {
                bondType = .single
            }

            mol.bonds.append(VisualizeBond(from: tId, to: newCarbon.id, type: bondType))
        }

        // Set the entire molecule at once.
        builder.setMolecule(mol)
        molecule = builder.molecule
        updateMetadata()
    }

    func addHydrogen() {
        saveState()

        var mol = builder.molecule

        // Find the most-recently added carbon that still has free valency.
        let targetCarbon = mol.atoms
            .filter { $0.element == .carbon }
            .reversed()
            .first { mol.valency(for: $0.id) < $0.element.maxBonds }

        guard let carbon = targetCarbon else { return }

        let bondLength: Float = 2.5
        let slots: [SIMD3<Float>] = [
            SIMD3<Float>( 0.577,  0.577,  0.577),
            SIMD3<Float>( 0.577, -0.577, -0.577),
            SIMD3<Float>(-0.577,  0.577, -0.577),
            SIMD3<Float>(-0.577, -0.577,  0.577)
        ]

        // Find which tetrahedral slots are already occupied.
        let connectedIds = mol.getConnections(for: carbon.id)
        var occupiedSlots = Set<Int>()
        for id in connectedIds {
            guard let atom = mol.atom(with: id) else { continue }
            let dir = atom.position - carbon.position
            let best = slots.enumerated().max {
                slots[$0.offset].x*dir.x + slots[$0.offset].y*dir.y + slots[$0.offset].z*dir.z <
                slots[$1.offset].x*dir.x + slots[$1.offset].y*dir.y + slots[$1.offset].z*dir.z
            }?.offset ?? 0
            occupiedSlots.insert(best)
        }

        // Place hydrogen in the first free slot.
        let chosenDir = slots.enumerated().first { !occupiedSlots.contains($0.offset) }?.element ?? slots[0]
        let newH = VisualizeAtom(position: carbon.position + chosenDir * bondLength, element: .hydrogen)
        mol.atoms.append(newH)
        mol.bonds.append(VisualizeBond(from: carbon.id, to: newH.id, type: .single))

        builder.setMolecule(mol)
        molecule = builder.molecule
        updateMetadata()
    }

    func removeHydrogen() {
        saveState()
        if let lastH = builder.molecule.atoms.filter({ $0.element == .hydrogen }).last {
            builder.removeAtom(lastH)
            molecule = builder.molecule
            updateMetadata()
        }
    }

    func removeCarbon() {
        saveState()
        guard let lastCarbon = builder.molecule.atoms.filter({ $0.element == .carbon }).last else { return }

        // Remove attached hydrogens before removing the carbon itself.
        let connectedH = builder.molecule.getConnections(for: lastCarbon.id)
            .compactMap { builder.molecule.atom(with: $0) }
            .filter { $0.element == .hydrogen }
        for h in connectedH {
            builder.removeAtom(h)
        }
        builder.removeAtom(lastCarbon)
        molecule = builder.molecule
        updateMetadata()
    }

    func undo() {
        guard !history.isEmpty else { return }
        builder.setMolecule(history.removeLast())
        molecule = builder.molecule
        updateMetadata()
    }

    func clear() {
        saveState()
        builder.clear()
        history.removeAll()
        molecule = builder.molecule
        updateMetadata()
    }

    // Private Helpers

    private func saveState() {
        history.append(molecule)
        if history.count > 20 { history.removeFirst() }
    }

    private func updateMetadata() {
        guard !molecule.atoms.isEmpty else {
            moleculeName         = ""
            chemicalFormula      = "-"
            missingHydrogensText = nil
            return
        }

        moleculeName    = VisualizeIUPACNamingLogic.generateName(for: molecule)
        chemicalFormula = molecule.chemicalFormula   

        let carbonCount   = molecule.atoms.filter { $0.element == .carbon }.count
        let hydrogenCount = molecule.atoms.filter { $0.element == .hydrogen }.count

        if carbonCount > 0 {
            // For a saturated chain: CnH(2n+2). Each extra bond order reduces H by 2.
            let extraBondOrders = molecule.bonds.reduce(0) { $0 + max(0, $1.type.rawValue - 1) }
            let maxH = max(0, (2 * carbonCount + 2) - 2 * extraBondOrders)
            let missing = maxH - hydrogenCount
            missingHydrogensText = missing > 0 ? "(-\(missing)H)" : nil
        } else {
            missingHydrogensText = nil
        }
    }
}
