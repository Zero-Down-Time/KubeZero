import 'builder.just'
import 'common.just'
import 'git.just'

prepare:
  uv sync --locked --no-install-project --no-editable

# requires 1.45 [arg('target', pattern='(release)?')]
fmt target="":
  uv run --extra dev autopep8 -ir .

# requires 1.45 [arg('target', pattern='(release)?')]
lint target="":
  uv run --extra dev flake8 .

# requires 1.45 [arg('target', pattern='(release)?')]
build target="":
  uv build --clear

# requires 1.45 [arg('target', pattern='(release)?')]
test target="":
  uv run --extra dev pytest --log-cli-level=DEBUG

clean:
  rm -rf .venv .pytest_cache dist

test_upload:
	uv publish --index testpypi --dry-run

upload:
  uv publish
