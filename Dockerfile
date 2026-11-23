FROM python:3.12-slim

# The installer requires curl (and certificates) to download the release archive
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

ENV UV_COMPILE_BYTECODE=1 UV_NO_CACHE=1

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --no-dev --frozen --no-install-project

COPY README.md LICENSE ./
COPY src ./src
RUN uv sync --no-dev --frozen
COPY data/samples ./data/samples

RUN useradd --create-home app
RUN mkdir -p /data
RUN chown app /data

####################################

USER app
ENV PATH="$PATH:/app/.venv/bin"
ENV HERON_DB=/data/verdicts.db
ENTRYPOINT ["heron"]
CMD ["/app/data/samples"]
