#syntax=docker/dockerfile:1.9
ARG PYTHON_VERSION=3.11

FROM ghcr.io/astral-sh/uv:0.4.9 AS uv
FROM python:${PYTHON_VERSION}-slim-bookworm

WORKDIR /root

RUN useradd --create-home --shell /bin/bash flytekit && \
    chown -R flytekit /root && chown -R flytekit /home

ENV VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH=/root \
    UV_LINK_MODE=copy \
    FLYTE_SDK_RICH_TRACEBACKS=0

ARG UNION_VERSION
RUN --mount=type=cache,sharing=locked,mode=0777,target=/root/.cache/uv,id=uv \
    --mount=from=uv,source=/uv,target=/usr/bin/uv \
    python -m venv $VIRTUAL_ENV && \
    uv pip install --python $VIRTUAL_ENV union==${UNION_VERSION}

USER flytekit

