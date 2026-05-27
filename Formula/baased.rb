# Homebrew formula for the ``baased`` CLI.
#
# Source-of-truth here; the ``bump-homebrew-tap`` workflow opens PRs
# against ``teicorian/homebrew-baased`` whenever a ``v*`` tag ships.
#
# End-user install:
#     brew tap teicorian/baased
#     brew install baased
#
# Installs from PyPI (the ``release-baased-cli`` workflow publishes
# ``baased-cli`` to PyPI on each ``v*`` tag), so it works regardless
# of whether the monorepo source is public.
class Baased < Formula
  include Language::Python::Virtualenv

  desc "App-author CLI for the baased platform"
  homepage "https://github.com/teicorian/baased"
  url "https://files.pythonhosted.org/packages/source/b/baased-cli/baased_cli-0.4.1.tar.gz"
  sha256 "1b13095d6a631ca9c06bf0d3067eb46b698b545bb3efcf0a77326c16f50ae5fa"
  license "Apache-2.0"

  depends_on "python@3.13"

  def install
    venv = virtualenv_create(libexec, "python3.13")
    # Let pip resolve transitive deps directly from PyPI rather than
    # pinning each one as a ``resource`` block. Simpler to maintain;
    # the CLI's dep list is small (httpx + pyyaml + sqlglot + pyseto
    # + argon2-cffi + pydantic) and we don't need bit-for-bit
    # reproducibility for a CLI.
    venv.pip_install_and_link buildpath
  end

  test do
    assert_match "baased", shell_output("#{bin}/baased --help")
  end
end
