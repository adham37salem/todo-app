package com.ybrd.todo.service;

import java.util.List;
import java.util.Optional;

import com.ybrd.todo.entity.model.Todo;

public interface ITodoService {
    public List<Todo> getAllTodos();
    public Optional<Todo> getTodoById(Long id);
    public Todo create(Todo todo);
    public Todo update(Long id, Todo todo);
    public void delete(Long id);
}
