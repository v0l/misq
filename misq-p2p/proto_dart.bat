@echo off

mkdir lib\proto_dart

protoc --dart_out=lib\proto_dart proto\proto_v1.2.0.proto

