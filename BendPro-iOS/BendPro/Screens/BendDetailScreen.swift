import SwiftUI
import BendProCore

private let LEAD_IN: Double = 3.0

public struct BendDetailScreen: View {
    public let kind: BendKind
    public let unit: LengthUnit
    public let bender: Bender
    @ObservedObject public var detailVM: DetailViewModel
    public var onOpenBenderPicker: () -> Void
    public var onSaveHistory: (HistoryEntry) -> Void

    public init(
        kind: BendKind,
        unit: LengthUnit,
        bender: Bender,
        detailVM: DetailViewModel,
        onOpenBenderPicker: @escaping () -> Void,
        onSaveHistory: @escaping (HistoryEntry) -> Void
    ) {
        self.kind = kind
        self.unit = unit
        self.bender = bender
        self.detailVM = detailVM
        self.onOpenBenderPicker = onOpenBenderPicker
        self.onSaveHistory = onSaveHistory
    }

    public var body: some View {
        let state = detailVM.getState(for: kind)
        let result = calculateResult(kind: kind, state: state, bender: bender)

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Bender Selection Row & Conduit size chips (shown for all except wirefill)
                if kind != .wirefill {
                    BenderSelectRow(
                        bender: bender,
                        selectedSize: state.tradeSizeIn,
                        onClick: onOpenBenderPicker
                    )

                    // Conduit Sizes Chips
                    conduitSizeRow(state: state)
                }

                // Inputs Section
                inputsSection(state: state)

                // Marks on Conduit & Calculations Section
                resultsSection(result: result)

                // Diagram Card
                BendDiagramView(result: result)

                // Status Pill
                HStack {
                    Spacer()
                    StatusPillView(feasibility: result.feasibility)
                    Spacer()
                }

                // Save to history button
                Button(action: {
                    let entry = detailVM.saveHistoryEntry(kind: kind, unit: unit, bender: bender)
                    onSaveHistory(entry)
                }) {
                    Text(state.saved ? "Saved ✓" : "Save to history")
                        .font(.poppins(.semibold, size: 14.5))
                        .foregroundColor(state.saved ? .colorOk : .accent)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.bgPanelRaised)
                        .cornerRadius(AppRadius.lg)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.lg)
                                .stroke(state.saved ? Color.colorOk.opacity(0.3) : Color.lineSoft, lineWidth: 1)
                        )
                }
                .accessibilityLabel(state.saved ? "Calculation saved" : "Save to history")
            }
            .padding(16)
        }
        .background(Color.bgVoid)
    }

    @ViewBuilder
    private func conduitSizeRow(state: BendDetailState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CONDUIT")
                .font(.poppins(.semibold, size: 11))
                .tracking(0.8)
                .foregroundColor(.textTertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    let supportedSizes = TRADE_SIZES.filter { bender.conduitSizesIn.contains($0) }
                    ForEach(supportedSizes, id: \.self) { size in
                        let isActive = (size == state.tradeSizeIn)
                        Button(action: {
                            detailVM.setTradeSize(kind: kind, sizeIn: size)
                        }) {
                            Text(tradeSizeLabel(size))
                                .font(.appMono(size: 13, weight: .semibold))
                                .foregroundColor(isActive ? .accent : .textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .frame(minHeight: 40)
                                .background(isActive ? Color.accentWash : Color.bgPanel)
                                .cornerRadius(999)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 999)
                                        .stroke(isActive ? Color.accent : Color.line, lineWidth: 1)
                                )
                        }
                        .accessibilityLabel("Conduit size \(tradeSizeLabel(size))\(isActive ? ", selected" : "")")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func inputsSection(state: BendDetailState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INPUTS")
                .font(.poppins(.semibold, size: 11))
                .tracking(0.8)
                .foregroundColor(.textTertiary)

            switch kind {
            case .offset:
                ValueInput(
                    label: "RISE",
                    valueIn: state.offsetIn,
                    onChangeIn: { detailVM.setOffset(kind: .offset, offsetIn: $0) },
                    unit: unit,
                    maxIn: 24
                )
                angleChipsRow(selectedAngle: state.angleDeg) {
                    detailVM.setAngle(kind: .offset, angleDeg: $0)
                }

            case .ninety:
                ValueInput(
                    label: "STUB LENGTH",
                    valueIn: state.stubHeightIn,
                    onChangeIn: { detailVM.setStubHeight(kind: .ninety, stubHeightIn: $0) },
                    unit: unit,
                    maxIn: 60
                )

            case .kick:
                ValueInput(
                    label: "RISE",
                    valueIn: state.riseIn,
                    onChangeIn: { detailVM.setRise(kind: .kick, riseIn: $0) },
                    unit: unit,
                    maxIn: 24
                )
                angleChipsRow(selectedAngle: state.angleDeg) {
                    detailVM.setAngle(kind: .kick, angleDeg: $0)
                }

            case .saddle3:
                ValueInput(
                    label: "OBSTRUCTION DEPTH",
                    valueIn: state.depthIn,
                    onChangeIn: { detailVM.setDepth(kind: .saddle3, depthIn: $0) },
                    unit: unit,
                    maxIn: 12
                )

            case .kick90:
                ValueInput(
                    label: "KICK OFFSET",
                    valueIn: state.kickOffsetIn,
                    onChangeIn: { detailVM.setKickOffset(kind: .kick90, kickOffsetIn: $0) },
                    unit: unit,
                    maxIn: 12
                )
                ValueInput(
                    label: "STUB LENGTH (FROM FINISHED END)",
                    valueIn: state.kick90StubIn,
                    onChangeIn: { detailVM.setKick90Stub(kind: .kick90, kick90StubIn: $0) },
                    unit: unit,
                    maxIn: 60
                )
                angleChipsRow(selectedAngle: state.angleDeg) {
                    detailVM.setAngle(kind: .kick90, angleDeg: $0)
                }

            case .segmented:
                PlainField(
                    label: "TOTAL SWEEP ANGLE",
                    suffix: "°",
                    value: state.totalAngleDeg,
                    onChange: { detailVM.setTotalAngle(kind: .segmented, totalAngleDeg: $0) },
                    min: 1,
                    max: 180
                )
                ValueInput(
                    label: "BEND RADIUS",
                    valueIn: state.radiusIn,
                    onChangeIn: { detailVM.setRadius(kind: .segmented, radiusIn: $0) },
                    unit: unit,
                    maxIn: 60
                )
                PlainField(
                    label: "NUMBER OF SHOTS",
                    suffix: "shots",
                    value: Double(state.shots),
                    onChange: { detailVM.setShots(kind: .segmented, shots: Int($0)) },
                    min: 2,
                    max: 20,
                    isInteger: true
                )

            case .saddle4:
                ValueInput(
                    label: "OBSTRUCTION DEPTH",
                    valueIn: state.depthIn,
                    onChangeIn: { detailVM.setDepth(kind: .saddle4, depthIn: $0) },
                    unit: unit,
                    maxIn: 12
                )
                ValueInput(
                    label: "OBSTRUCTION WIDTH (FLAT TOP)",
                    valueIn: state.obstructionWidthIn,
                    onChangeIn: { detailVM.setObstructionWidth(kind: .saddle4, widthIn: $0) },
                    unit: unit,
                    maxIn: 36
                )

            case .rolling:
                ValueInput(
                    label: "VERTICAL OFFSET",
                    valueIn: state.rollingVerticalIn,
                    onChangeIn: { detailVM.setRollingVertical(kind: .rolling, verticalIn: $0) },
                    unit: unit,
                    maxIn: 24
                )
                ValueInput(
                    label: "HORIZONTAL OFFSET",
                    valueIn: state.rollingHorizontalIn,
                    onChangeIn: { detailVM.setRollingHorizontal(kind: .rolling, horizontalIn: $0) },
                    unit: unit,
                    maxIn: 24
                )
                angleChipsRow(selectedAngle: state.angleDeg) {
                    detailVM.setAngle(kind: .rolling, angleDeg: $0)
                }

            case .wirefill:
                wirefillInputs(state: state)
            }
        }
    }

    @ViewBuilder
    private func wirefillInputs(state: BendDetailState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Conduit size chips (EMT)
            VStack(alignment: .leading, spacing: 8) {
                Text("CONDUIT SIZE (EMT)")
                    .font(.poppins(.semibold, size: 11))
                    .tracking(0.8)
                    .foregroundColor(.textTertiary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(TRADE_SIZES, id: \.self) { size in
                            let isActive = (size == state.wireConduitSizeIn)
                            Button(action: {
                                detailVM.setWireConduitSize(kind: .wirefill, sizeIn: size)
                            }) {
                                Text(tradeSizeLabel(size))
                                    .font(.appMono(size: 13, weight: .semibold))
                                    .foregroundColor(isActive ? .accent : .textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .frame(minHeight: 40)
                                    .background(isActive ? Color.accentWash : Color.bgPanel)
                                    .cornerRadius(999)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 999)
                                            .stroke(isActive ? Color.accent : Color.line, lineWidth: 1)
                                    )
                            }
                            .accessibilityLabel("Conduit size \(tradeSizeLabel(size))\(isActive ? ", selected" : "")")
                        }
                    }
                }
            }

            // Wire size chips (AWG)
            VStack(alignment: .leading, spacing: 8) {
                Text("WIRE SIZE (AWG, THHN/THWN)")
                    .font(.poppins(.semibold, size: 11))
                    .tracking(0.8)
                    .foregroundColor(.textTertiary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(WIRE_AWG_OPTIONS, id: \.self) { awg in
                            let isActive = (awg == state.wireAwg)
                            Button(action: {
                                detailVM.setWireAwg(kind: .wirefill, awg: awg)
                            }) {
                                Text(awg)
                                    .font(.appMono(size: 13, weight: .semibold))
                                    .foregroundColor(isActive ? .accent : .textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .frame(minHeight: 40)
                                    .background(isActive ? Color.accentWash : Color.bgPanel)
                                    .cornerRadius(999)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 999)
                                            .stroke(isActive ? Color.accent : Color.line, lineWidth: 1)
                                    )
                            }
                            .accessibilityLabel("Wire size \(awg) AWG\(isActive ? ", selected" : "")")
                        }
                    }
                }
            }

            // Number of conductors plain field
            PlainField(
                label: "NUMBER OF CONDUCTORS",
                suffix: "ct",
                value: Double(state.wireCount),
                onChange: { detailVM.setWireCount(kind: .wirefill, count: Int($0)) },
                min: 1,
                max: 40,
                isInteger: true
            )
        }
    }

    @ViewBuilder
    private func angleChipsRow(selectedAngle: Double, onSelect: @escaping (Double) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ANGLE")
                .font(.poppins(.semibold, size: 11))
                .tracking(0.8)
                .foregroundColor(.textTertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(OFFSET_ANGLES, id: \.self) { angle in
                        let isActive = (angle == selectedAngle)
                        Button(action: { onSelect(angle) }) {
                            Text("\(formatAngle(angle))°")
                                .font(.appMono(size: 13, weight: .semibold))
                                .foregroundColor(isActive ? .accent : .textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .frame(minHeight: 40)
                                .background(isActive ? Color.accentWash : Color.bgPanel)
                                .cornerRadius(999)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 999)
                                        .stroke(isActive ? Color.accent : Color.line, lineWidth: 1)
                                )
                        }
                        .accessibilityLabel("Angle \(formatAngle(angle)) degrees\(isActive ? ", selected" : "")")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func resultsSection(result: BendResult) -> some View {
        switch result {
        case let r as OffsetResult:
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("MARKS ON CONDUIT")
                VStack(spacing: 6) {
                    markRow(label: "Mark 1", value: formatLength(LEAD_IN, unit: unit))
                    markRow(label: "Mark 2", value: formatLength(LEAD_IN + r.distanceBetweenBendsIn, unit: unit))
                }

                sectionHeader("CALCULATIONS")
                VStack(spacing: 6) {
                    calcRow(label: "Spacing", value: formatLength(r.distanceBetweenBendsIn, unit: unit))
                    calcRow(label: "Shrink", value: formatLength(r.shrinkIn, unit: unit, precision: 3))
                }
            }

        case let r as NinetyResult:
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("MARKS ON CONDUIT")
                VStack(spacing: 6) {
                    markRow(label: "Mark 1", value: formatLength(r.markIn, unit: unit))
                }

                sectionHeader("CALCULATIONS")
                VStack(spacing: 6) {
                    calcRow(label: "Deduct", value: formatLength(r.deductIn, unit: unit))
                    calcRow(label: "Gain", value: formatLength(max(r.deductIn * 0.36, 0.1), unit: unit, precision: 2))
                    calcRow(label: "Mark", value: formatLength(r.markIn, unit: unit))
                }
            }

        case let r as KickResult:
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("MARKS ON CONDUIT")
                VStack(spacing: 6) {
                    markRow(label: "Mark", value: formatLength(r.distanceToMarkIn, unit: unit))
                }

                sectionHeader("CALCULATIONS")
                VStack(spacing: 6) {
                    calcRow(label: "Gain", value: formatLength(r.gainIn, unit: unit, precision: 3))
                }
            }

        case let r as Saddle3Result:
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("MARKS ON CONDUIT")
                VStack(spacing: 6) {
                    markRow(label: "Center → Side", value: formatLength(r.centerToSideIn, unit: unit))
                }

                sectionHeader("CALCULATIONS")
                VStack(spacing: 6) {
                    calcRow(label: "Total gain", value: formatLength(r.totalGainIn, unit: unit, precision: 3))
                }
            }

        case let r as Kick90Result:
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("MARKS ON CONDUIT")
                VStack(spacing: 6) {
                    markRow(label: "Mark 1 · from start", value: formatLength(r.kickMarkIn, unit: unit))
                    markRow(label: "Mark 2 · from end", value: formatLength(r.stubMarkIn, unit: unit))
                }

                sectionHeader("CALCULATIONS")
                VStack(spacing: 6) {
                    calcRow(label: "90° deduct", value: formatLength(r.deductIn, unit: unit))
                }
            }

        case let r as SegmentedResult:
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("CALCULATIONS")
                VStack(spacing: 6) {
                    calcRow(label: "Angle per shot", value: String(format: "%.1f°", r.anglePerShotDeg))
                    calcRow(label: "Distance between shots", value: formatLength(r.distanceBetweenShotsIn, unit: unit))
                }
            }

        case let r as Saddle4Result:
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("MARKS ON CONDUIT")
                VStack(spacing: 6) {
                    markRow(label: "Inner pair · spacing", value: formatLength(r.innerSpacingIn, unit: unit))
                    markRow(label: "Outer · beyond each inner", value: formatLength(r.outerFromInnerIn, unit: unit))
                }

                sectionHeader("CALCULATIONS")
                VStack(spacing: 6) {
                    calcRow(label: "All 4 bends", value: String(format: "%.1f°", r.sideAngleDeg))
                    calcRow(label: "Total gain", value: formatLength(r.totalGainIn, unit: unit, precision: 3))
                }
            }

        case let r as RollingOffsetResult:
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("MARKS ON CONDUIT")
                VStack(spacing: 6) {
                    markRow(label: "Mark 1", value: formatLength(LEAD_IN, unit: unit))
                    markRow(label: "Mark 2", value: formatLength(LEAD_IN + r.distanceBetweenBendsIn, unit: unit))
                }

                sectionHeader("CALCULATIONS")
                VStack(spacing: 6) {
                    calcRow(label: "True offset", value: formatLength(r.trueOffsetIn, unit: unit))
                    calcRow(label: "Roll angle", value: String(format: "%.1f°", r.rollAngleDeg))
                    calcRow(label: "Shrink", value: formatLength(r.shrinkIn, unit: unit, precision: 3))
                }
            }

        case let r as WireFillResult:
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("CALCULATIONS")
                VStack(spacing: 6) {
                    calcRow(label: "Conduit area", value: String(format: "%.3f sq in", r.conduitAreaSqIn))
                    calcRow(label: "Conductor area", value: String(format: "%.4f sq in", r.totalConductorAreaSqIn))
                    calcRow(label: "Fill (max \(r.maxFillPct)%)", value: String(format: "%.1f%%", r.fillPct))
                }

                Text("EMT and THHN/THWN only, approximate NEC Chapter 9 subset — not verified against a specific code edition. Verify against the current NEC tables for other conduit or wire types.")
                    .font(.poppins(.regular, size: 11))
                    .foregroundColor(.textTertiary)
                    .lineSpacing(4)
                    .padding(.top, 4)
            }

        default:
            EmptyView()
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.poppins(.semibold, size: 11))
            .tracking(0.8)
            .foregroundColor(.textTertiary)
    }

    private func markRow(label: String, value: String) -> some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.accent)
                    .frame(width: 6, height: 6)
                Text(label)
                    .font(.poppins(.medium, size: 13.5))
                    .foregroundColor(.textPrimary)
            }
            Spacer()
            Text(value)
                .font(.appMono(size: 14.5, weight: .semibold))
                .foregroundColor(.accent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.bgPanel)
        .cornerRadius(AppRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(Color.lineSoft, lineWidth: 1)
        )
    }

    private func calcRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.poppins(.medium, size: 13.5))
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.appMono(size: 14.5, weight: .regular))
                .foregroundColor(.metal200)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.bgPanel)
        .cornerRadius(AppRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(Color.lineSoft, lineWidth: 1)
        )
    }
}
