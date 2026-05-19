# Homebrew formula for the ``baased`` CLI.
#
# Lives in this repo for source-of-truth + reviewability. The actual
# tap that Homebrew reads from is the separate repo
# ``teicorian/homebrew-baased``; copy this file into that tap's
# ``Formula/`` directory and tag a release here whenever the CLI
# version changes.
#
# End-user install:
#
#     brew tap teicorian/baased
#     brew install baased
#
# Maintainer release flow:
#
#   1. Bump ``packages/baased-cli/pyproject.toml`` ``version``.
#   2. Tag this repo:        ``git tag v0.1.0 && git push --tags``
#   3. Update ``url`` + ``sha256`` below to point at the new tag's
#      tarball:
#        curl -L https://github.com/teicorian/baased/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
#   4. Refresh dependency resources (one-time per release):
#        brew update-python-resources Formula/baased.rb
#   5. Copy this file into the ``homebrew-baased`` tap and push.
#   6. Verify: ``brew tap teicorian/baased && brew install --build-from-source baased && baased --help``
class Baased < Formula
  include Language::Python::Virtualenv

  desc "App-author CLI for the baased platform"
  homepage "https://github.com/teicorian/baased"
  url "https://github.com/teicorian/baased/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256_OF_THE_TAGGED_TARBALL"
  license "Apache-2.0"
  head "https://github.com/teicorian/baased.git", branch: "main"

  depends_on "python@3.12"

  # ── Python dependency resources ───────────────────────────────────
  # Generated with ``brew update-python-resources Formula/baased.rb``.
  # The CLI depends on the workspace root ``baased`` package (for
  # ``libs.schema_loader`` + ``libs.auth``) and on httpx + pyyaml.
  # Re-run the resource refresh whenever pyproject.toml deps change.
  #
  # resource "httpx" do
  #   url "https://files.pythonhosted.org/packages/.../httpx-0.27.x.tar.gz"
  #   sha256 "..."
  # end
  # resource "pyyaml" do
  #   url "https://files.pythonhosted.org/packages/.../PyYAML-6.0.x.tar.gz"
  #   sha256 "..."
  # end
  # resource "pyseto" do
  #   url "https://files.pythonhosted.org/packages/.../pyseto-1.7.x.tar.gz"
  #   sha256 "..."
  # end
  # ... (full transitive list filled in by ``brew update-python-resources``)

  def install
    # Install the workspace root (provides ``libs/``) then the CLI
    # package. Both are sdists inside the same source tarball.
    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install resources
    venv.pip_install buildpath
    venv.pip_install_and_link buildpath/"packages/baased-cli"
  end

  test do
    # Smoke test: the CLI parser loads without hitting the network.
    assert_match "baased", shell_output("#{bin}/baased --help")
  end
end
