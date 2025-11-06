package com.benchmark.variant_a_jersey.api;

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
@Path("/items")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ItemResource {

    @Autowired
    private ItemRepository repository;

    @GET
    public Response list(@QueryParam("page") @DefaultValue("0") int page,
                         @QueryParam("size") @DefaultValue("20") int size,
                         @QueryParam("categoryId") Long categoryId) {
        PageRequest pageable = PageRequest.of(page, size);
        Page<Item> result = (categoryId == null)
                ? repository.findAll(pageable)
                : repository.findByCategoryId(categoryId, pageable);
        return Response.ok(result).build();
    }

    @GET
    @Path("/{id}")
    public Response byId(@PathParam("id") Long id) {
        return repository.findById(id)
                .map(i -> Response.ok(i).build())
                .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }

    @POST
    public Response create(@Valid @NotNull Item payload, @Context UriInfo uriInfo) {
        Item saved = repository.save(payload);
        URI location = uriInfo.getAbsolutePathBuilder().path(String.valueOf(saved.getId())).build();
        return Response.created(location).entity(saved).build();
    }

    @PUT
    @Path("/{id}")
    public Response update(@PathParam("id") Long id, @Valid @NotNull Item payload) {
        Optional<Item> opt = repository.findById(id);
        if (opt.isEmpty()) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        Item i = opt.get();
        i.setSku(payload.getSku());
        i.setName(payload.getName());
        i.setPrice(payload.getPrice());
        i.setStock(payload.getStock());
        i.setCategory(payload.getCategory());
        i.setUpdatedAt(payload.getUpdatedAt());
        return Response.ok(repository.save(i)).build();
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
}
