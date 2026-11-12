// ==============================================================================
// Wonderland: Project Aetheris // Vector Query Drawer View
// File: ui/VectorQueryDrawerView.swift
// ==============================================================================

import SwiftUI

public struct VectorQueryDrawerView: View {
    @ObservedObject public var viewModel: WonderlandRuntimeViewModel

    public init(viewModel: WonderlandRuntimeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            self.headerView
            self.searchParamsView
            Divider().background(Color.cyan.opacity(0.3))
            self.neighborsSectionView
        }
        .padding(16)
        .background(Color.black.opacity(0.4))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
        )
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "magnifyingglass.circle")
                .foregroundColor(.cyan)
            Text("VECTOR SIMD QUERY ENGINE")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
            Spacer()
        }
    }

    private var searchParamsView: some View {
        HStack(spacing: 12) {
            Text("METRIC: COSINE")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary)
            Spacer()
            Button(action: { self.viewModel.dispatchBenchmarkCommand() }) {
                Text("EXECUTE SEARCH")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
    }

    private var neighborsSectionView: some View {
        VStack(alignment: .leading, spacing: 6) {
            self.topKHeaderView
            self.neighborListScrollView
        }
    }

    private var topKHeaderView: some View {
        Text("TOP-K NEIGHBORS")
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .foregroundColor(.gray)
    }

    private var neighborListScrollView: some View {
        ScrollView {
            VStack(spacing: 6) {
                self.neighborRow(index: "01", partition: "partition_alpha", score: "0.9842")
                self.neighborRow(index: "02", partition: "partition_beta", score: "0.9126")
                self.neighborRow(index: "03", partition: "partition_gamma", score: "0.8734")
            }
        }
        .frame(maxHeight: 140)
    }

    private func neighborRow(index: String, partition: String, score: String) -> some View {
        HStack {
            Text("#\(index)")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
            Text(partition)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.white)
            Spacer()
            Text(score)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color.white.opacity(0.02))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
