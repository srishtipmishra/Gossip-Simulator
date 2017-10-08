defmodule Gossip_Entry do
    use GenServer 

    def main(args) do

        [num|t] = args 
        [topology|tail] = t 
        [algorithm|t2] = tail

        num_nodes = String.to_integer(num)
        case topology do
            "full" ->
                create_full(num_nodes,algorithm)
            "2D" ->
                create_2D(num_nodes,algorithm)
            "imp2D" ->
                create_imp2D(num_nodes,algorithm)
            "line" -> 
                create_line(num_nodes,algorithm)
        end  
        Process.sleep(:infinity)
    end

    def create_topology(num_nodes,topology,algorithm) do
        init_state = []
        num_nodes = round(num_nodes)
        IO.puts "num nodes in create #{num_nodes}"
        node_list = Enum.to_list(1..num_nodes)
        case algorithm do
            "gossip" ->
                Enum.each node_list, fn node-> Gossip.start_link(node,0) end
                start_node = Enum.random(node_list)
                start_time = DateTime.utc_now()
                Gossip.gossip(start_node,num_nodes,topology,start_time)

            "push-sum" -> 
                Enum.each node_list, fn node -> Push_Sum.start_link(node,1,0) end 
                start_node = Enum.random(node_list)
                start_time = DateTime.utc_now()
                Push_Sum.push_sum(start_node,0,1,topology,num_nodes,start_time)
        end
        
    end

    def create_full(num_nodes,algorithm) do
        create_topology(num_nodes,"full",algorithm)
    end

    def create_line(num_nodes,algorithm) do
        create_topology(num_nodes,"line",algorithm)    
    end

    def create_2D(num_nodes,algorithm) do
        IO.puts "in create 2d"
        case is_sqrt_natural?(num_nodes) do
             :true -> 
                 nodes_number = num_nodes
             :false -> 
                 square_root = :math.sqrt(num_nodes)
                 nodes_number = :math.pow(Float.ceil(square_root),2)
        end
        create_topology(round(nodes_number),"2D",algorithm)
    end

    def create_imp2D(num_nodes,algorithm) do
        case is_sqrt_natural?(num_nodes) do
             :true -> 
                 nodes_number = num_nodes
             :false -> 
                 square_root = :math.sqrt(num_nodes)
                 nodes_number = :math.pow(Float.ceil(square_root),2)
        end
        create_topology(round(nodes_number),"imp2D",algorithm)
    end

    defp is_sqrt_natural?(n) when is_integer(n) do
        :math.sqrt(n) |> :erlang.trunc |> :math.pow(2) == n
    end

    defp is_sqrt_natural?(_n) do
        false
    end

end