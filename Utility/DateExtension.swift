//
//  Untitled.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 05/10/24.
//
import Foundation

func formatDateToDDMMMYYYY(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM yyyy"
    return dateFormatter.string(from: date)
}

func formatDateToDDMMYY(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yy"
    return dateFormatter.string(from: date)
}

func getFormattedDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}
