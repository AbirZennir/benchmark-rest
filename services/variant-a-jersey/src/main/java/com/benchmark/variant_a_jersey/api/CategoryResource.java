package com.benchmark.variant_a_jersey.api;

import com.benchmark.variant_a_jersey.domain.Category;
import com.benchmark.variant_a_jersey.repository.CategoryRepository;
import com.benchmark.variant_a_jersey.domain.Item;
import com.benchmark.variant_a_jersey.repository.ItemRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.UriInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.util.Optional;

@Component
@Path("/categories")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CategoryResource {

    @Autowired
    private CategoryRepository repository;
    @Autowired
    private ItemRepository itemRepository;

    @GET
    public Response all(@QueryParam("page") @DefaultValue("0") int page,
                        @QueryParam("size") @DefaultValue("20") int size) {
        Page<Category> result = repository.findAll(PageRequest.of(page, size));
        return Response.ok(result).build();
    }

    @GET
    @Path("/{id}")
    public Response byId(@PathParam("id") Long id) {
        return repository.findById(id)
                .map(c -> Response.ok(c).build())
                .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }

    @POST
    public Response create(@Valid @NotNull Category payload, @Context UriInfo uriInfo) {
        Category saved = repository.save(payload);
        URI location = uriInfo.getAbsolutePathBuilder().path(String.valueOf(saved.getId())).build();
        return Response.created(location).entity(saved).build();
    }

    @PUT
    @Path("/{id}")
    public Response update(@PathParam("id") Long id, @Valid @NotNull Category payload) {
        Optional<Category> opt = repository.findById(id);
        if (opt.isEmpty()) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        Category c = opt.get();
        c.setCode(payload.getCode());
        c.setName(payload.getName());
        c.setUpdatedAt(payload.getUpdatedAt());
        return Response.ok(repository.save(c)).build();
    }

    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") Long id) {
        if (!repository.existsById(id)) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        repository.deleteById(id);
        return Response.noContent().build();
    }

    @GET
    @Path("/{id}/items")
    public Response itemsByCategory(@PathParam("id") Long id,
                                    @QueryParam("page") @DefaultValue("0") int page,
                                    @QueryParam("size") @DefaultValue("20") int size) {
        if (!repository.existsById(id)) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        Page<Item> result = itemRepository.findByCategoryId(id, PageRequest.of(page, size));
        return Response.ok(result).build();
    }
}
