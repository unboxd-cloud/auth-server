import type { Metadata } from "next"
import "./globals.css"

export const metadata: Metadata = {
  title: "Unboxd AuthServer — Secure Authentication Platform",
  description: "AgentFirst Decentralized Identity Platform. Enterprise-grade authentication with OAuth 2.0, OIDC, and JWT tokens.",
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}