import Link from "next/link"
import { Shield, Lock, Key, Users, Zap, Globe, ArrowRight, CheckCircle } from "lucide-react"

export default function Home() {
  return (
    <div className="min-h-screen bg-[#09090b] text-white">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 border-b border-white/5 bg-[#09090b]/80 backdrop-blur-xl">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <Link href="/" className="text-xl font-semibold tracking-tight">
            Unboxd <span className="text-[#d4a853]">AuthServer</span>
          </Link>
          <div className="hidden md:flex items-center gap-8 text-sm text-zinc-400">
            <Link href="#features" className="hover:text-white transition-colors">Features</Link>
            <Link href="#docs" className="hover:text-white transition-colors">Docs</Link>
            <Link href="/blog" className="hover:text-white transition-colors">Blog</Link>
            <Link href="https://authserver.unboxd.cloud/admin" className="hover:text-white transition-colors">Console</Link>
          </div>
        </div>
      </nav>

      {/* Hero */}
      <section className="pt-32 pb-20 px-6">
        <div className="max-w-4xl mx-auto text-center">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#d4a853]/10 text-[#d4a853] text-xs font-medium mb-8">
            <span className="w-2 h-2 rounded-full bg-[#d4a853] animate-pulse"></span>
            Now available at authserver.unboxd.cloud
          </div>
          <h1 className="text-5xl md:text-7xl font-light tracking-tight mb-6 leading-tight">
            Secure authentication
            <br />
            <span className="text-[#d4a853] italic">for modern apps</span>
          </h1>
          <p className="text-xl text-zinc-400 mb-10 max-w-2xl mx-auto leading-relaxed">
            AgentFirst Decentralized Identity Platform. Enterprise-grade authentication with OAuth 2.0, OIDC, and JWT tokens. Built for developers who demand both security and simplicity.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="https://authserver.unboxd.cloud/admin"
              className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-[#d4a853] text-black font-medium rounded-lg hover:bg-[#c99a47] transition-colors"
            >
              Get Started
              <ArrowRight className="w-4 h-4" />
            </Link>
            <Link
              href="#docs"
              className="inline-flex items-center justify-center gap-2 px-6 py-3 border border-white/10 text-white font-medium rounded-lg hover:bg-white/5 transition-colors"
            >
              View Documentation
            </Link>
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="py-20 px-6 border-t border-white/5">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-light text-center mb-16">Everything you need</h2>
          <div className="grid md:grid-cols-3 gap-6">
            <FeatureCard
              icon={<Shield className="w-6 h-6" />}
              title="OAuth 2.0 & OIDC"
              description="Full support for OAuth 2.0, OpenID Connect, and industry-standard protocols."
            />
            <FeatureCard
              icon={<Key className="w-6 h-6" />}
              title="JWT Tokens"
              description="Secure token generation and validation with RS256 signing."
            />
            <FeatureCard
              icon={<Zap className="w-6 h-6" />}
              title="Fast Integration"
              description="SDKs for Node.js, Python, Go, and more. Get started in minutes."
            />
            <FeatureCard
              icon={<Lock className="w-6 h-6" />}
              title="Enterprise Security"
              description="Rate limiting, CSRF protection, and encrypted token storage."
            />
            <FeatureCard
              icon={<Users className="w-6 h-6" />}
              title="User Federation"
              description="LDAP, Active Directory, and custom identity providers."
            />
            <FeatureCard
              icon={<Globe className="w-6 h-6" />}
              title="Global Scale"
              description="High availability deployment ready for production workloads."
            />
          </div>
        </div>
      </section>

      {/* Code Section */}
      <section className="py-20 px-6 bg-white/[0.02] border-t border-white/5">
        <div className="max-w-3xl mx-auto">
          <h2 className="text-3xl font-light text-center mb-4">Integrate in minutes</h2>
          <p className="text-zinc-400 text-center mb-10">Simple, secure authentication for your app</p>
          <div className="bg-[#111113] rounded-xl border border-white/10 p-6 font-mono text-sm overflow-x-auto">
            <pre className="text-zinc-400">{`// Install the SDK
npm install @unboxd/auth-sdk

// Initialize
const { Auth } = require('@unboxd/auth-sdk');
const auth = new Auth({
  clientId: 'your-client-id',
  redirectUri: 'https://yourapp.com/callback'
});

// Protect routes
app.get('/api', auth.protect(), (req, res) => {
  res.json({ user: req.user });
});`}</pre>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 px-6 border-t border-white/5">
        <div className="max-w-2xl mx-auto text-center">
          <h2 className="text-3xl font-light mb-6">Ready to get started?</h2>
          <p className="text-zinc-400 mb-8">
            Deploy your authentication infrastructure in minutes with our managed service.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="https://authserver.unboxd.cloud/admin"
              className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-[#d4a853] text-black font-medium rounded-lg hover:bg-[#c99a47] transition-colors"
            >
              Create Realm
              <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-10 px-6 border-t border-white/5">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row justify-between items-center gap-4">
          <div className="text-zinc-500 text-sm">
            © 2026 Unboxd AuthServer. All rights reserved.
          </div>
          <div className="flex items-center gap-6 text-sm text-zinc-500">
            <a href="#" className="hover:text-white transition-colors">GitHub</a>
            <a href="#" className="hover:text-white transition-colors">Twitter</a>
            <a href="#" className="hover:text-white transition-colors">Discord</a>
          </div>
        </div>
      </footer>
    </div>
  )
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode; title: string; description: string }) {
  return (
    <div className="p-6 rounded-xl bg-white/[0.02] border border-white/5 hover:border-[#d4a853]/30 transition-colors">
      <div className="w-12 h-12 rounded-lg bg-[#d4a853]/10 text-[#d4a853] flex items-center justify-center mb-4">
        {icon}
      </div>
      <h3 className="text-lg font-medium mb-2">{title}</h3>
      <p className="text-zinc-400 text-sm leading-relaxed">{description}</p>
    </div>
  )
}