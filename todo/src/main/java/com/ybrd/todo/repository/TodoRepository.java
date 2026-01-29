package com.ybrd.todo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ybrd.todo.entity.model.Todo;

@Repository
public interface TodoRepository extends JpaRepository<Todo, Long> {

}
