{
  lib,
  fetchFromGitHub,
  python3,
}:

with python3.pkgs;

buildPythonApplication rec {
  pname = "check-jsonschema";
  version = "0.30.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "python-jsonschema";
    repo = "check-jsonschema";
    tag = version;
    hash = "sha256-qaNSL7ZPEWJ8Zc/XPEWtUJYQnUJ7jNdla1I0d6+GReM=";
  };

  propagatedBuildInputs = [
    ruamel-yaml
    jsonschema
    requests
    click
    regress
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
    responses
  ];

  pythonImportsCheck = [
    "check_jsonschema"
    "check_jsonschema.cli"
  ];

  disabledTests = [
    "test_schemaloader_yaml_data"
  ];

  meta = with lib; {
    description = "Jsonschema CLI and pre-commit hook";
    mainProgram = "check-jsonschema";
    homepage = "https://github.com/python-jsonschema/check-jsonschema";
    changelog = "https://github.com/python-jsonschema/check-jsonschema/blob/${version}/CHANGELOG.rst";
    license = licenses.asl20;
    maintainers = with maintainers; [ sudosubin ];
  };
}
