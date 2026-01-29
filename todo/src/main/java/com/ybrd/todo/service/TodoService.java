package com.ybrd.todo.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.ybrd.todo.entity.model.Todo;
import com.ybrd.todo.repository.TodoRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TodoService implements ITodoService {
    
    private final TodoRepository todoRepository;
    
    @Override
    public List<Todo> getAllTodos() {
        return this.todoRepository.findAll();
    }

    @Override
    public Optional<Todo> getTodoById(Long id) {
       Todo todo = this.todoRepository.findById(id).orElseThrow(() -> new RuntimeException("Todo not found"));
       return Optional.of(todo);
    }

    @Override
    public Todo create(Todo todo) {
       Todo newTodo = Todo.builder()
        .title(todo.getTitle())
        .description(todo.getDescription())
        .completed(false)
        .createdAt(LocalDateTime.now())
        .build();
       return this.todoRepository.save(newTodo);
    }

    @Override
    public Todo update(Long id, Todo todoDetails) {
    
        Optional<Todo> todo = this.todoRepository.findById(id);
        if (todo.isPresent()) {
            Todo updatedTodo = Todo.builder()
            .id(todoDetails.getId())
            .title(todoDetails.getTitle())
            .description(todoDetails.getDescription())
            .completed(todoDetails.isCompleted())
            .createdAt(todoDetails.getCreatedAt())
            .updatedAt(LocalDateTime.now())
            .build();
            return this.todoRepository.save(updatedTodo);
        } else {
            throw new RuntimeException("Todo not found");
        }
    }

    @Override
    public void delete(Long id) {
       Optional<Todo> todo = this.todoRepository.findById(id);
       if (todo.isPresent()) {
        this.todoRepository.delete(todo.get());
       } else {
        throw new RuntimeException("Todo not found");
       }
    }

}
